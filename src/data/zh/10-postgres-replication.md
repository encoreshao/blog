---
title: "用 Vagrant 搭建 PostgreSQL 10 主从复制"
date: 2026-06-19
tags: [PostgreSQL, Infrastructure, DevEx]
excerpt: "团队只有一台数据库，没有备份节点。我用两台虚拟机把流复制从头搭了一遍，搞清楚每一步为什么这么做。"
draft: false
---

团队的数据库只有一台。没有备份节点，没有容灾，就一台机器扛着所有读写。大家都知道这不对，但也都在假装没这回事。

说起来也没人在骗谁。备份是有的，方案也是有的。方案就是"服务器挂了就从备份恢复"——这意味着宕机时间是小时级别，不是分钟级别。这种方案听起来合理，直到凌晨两点真的要执行它。

我想在真正需要用到之前，先把主从复制搞清楚。于是用 Vagrant 起了两台 VirtualBox 虚拟机，Ubuntu 18.04，PostgreSQL 10，花了一个周末。

## 先说环境

两台机器，两个 IP：

- 主库（Master）：`192.168.33.11`，负责读写
- 从库（Slave）：`192.168.33.22`，只读备用节点，跟着主库的 WAL 流走

Vagrant 的好处是随时可以删掉重来。那个周末我重来了不止一次。

## 主库的配置

主库上的每一次写操作——insert、update、delete——在真正落到数据文件之前，都会先写进 WAL。这个机制本来是为崩溃恢复设计的，但它同时也是从库订阅的数据流。你在主库要做的，就是把这个流暴露出来，给从库连接的权限。

先建一个复制用的角色：

```sql
CREATE ROLE replicate WITH REPLICATION LOGIN PASSWORD 'your-password';
```

然后改 `/etc/postgresql/10/main/postgresql.conf`：

```conf
listen_addresses = '*'
wal_level = replica
max_wal_senders = 3
wal_keep_segments = 64
```

`wal_level = replica` 是关键。没有这个，Postgres 不会生成流复制需要的 WAL 数据，后面全白做。`wal_keep_segments` 控制保留多少 WAL 段，给从库追进度留的缓冲。

还有一个文件容易被忽略：`pg_hba.conf`。要显式允许从库连进来做复制：

```conf
host    replication     replicate    192.168.33.22/32    md5
```

注意这里的数据库名写的是 `replication`，不是 `all`，也不是你的业务库名。这是 Postgres 专门给复制连接用的关键字。写错了，从库连接直接报认证失败，错误信息几乎不告诉你原因在哪。

两个文件改完，重启主库的 Postgres。

## 从库的配置

大多数教程到这里开始糊弄人，说"配置从库"好像两步就完事。麻烦其实在这里。

先把从库的 Postgres 停掉：

```bash
sudo service postgresql stop
```

然后把数据目录清空：

```bash
rm -rf /var/lib/postgresql/10/main/*
```

不用担心，这是 Postgres 安装时自动生成的空目录，里面没有你的业务数据。你要腾出空间，让接下来的 base backup 把主库的数据完整复制过来。

清完之后把权限补回去：

```bash
chmod 700 /var/lib/postgresql/10/main
chown postgres:postgres /var/lib/postgresql/10/main
```

然后以 postgres 用户身份跑 `pg_basebackup`：

```bash
sudo -u postgres pg_basebackup \
  -h 192.168.33.11 \
  -D /var/lib/postgresql/10/main/ \
  -P -U replicate \
  --wal-method=stream
```

这一步把主库的整个数据目录复制到从库，同时记录下备份时主库的 WAL 位置。从库之后就从这个位置开始订阅 WAL 流。`-P` 显示进度。新装的 Postgres 跑起来几秒钟，生产环境数据多就得等更长。

备份完成后，在从库数据目录里创建 `recovery.conf`：

```conf
standby_mode = 'on'
primary_conninfo = 'host=192.168.33.11 port=5432 user=replicate password=your-password'
trigger_file = '/tmp/MasterNow'
```

`standby_mode = 'on'` 告诉 Postgres 启动后继续待在 recovery 模式，持续跟随主库的 WAL 流，而不是完成 recovery 之后变成一个独立的主库。

`trigger_file` 是 failover 的开关。在从库上 `touch /tmp/MasterNow`，从库就停止跟随主库，把自己提升为主库。这是最原始的切换方式。

启动从库的 Postgres：

```bash
sudo service postgresql start
```

## 确认复制正常

先确认连接。在主库查：

```sql
SELECT * FROM pg_stat_activity WHERE usename = 'replicate';
```

能看到一行，说明从库连上来了，WAL 流已经在跑。一行都没有，说明从库根本没连进来——回去看 `pg_hba.conf`。我第一次就是那里写错了，从库报的认证失败几乎没给出任何有用的信息。

连接确认没问题之后，真正的验证是一次写操作。在主库建一个数据库：

```sql
CREATE DATABASE replication_test;
```

然后去从库查：

```sql
SELECT datname FROM pg_database WHERE datname = 'replication_test';
```

不到一秒就出来了。之前配的所有东西——WAL 级别、复制角色、base backup、recovery.conf——最终就是这一行出现在另一台机器上。那一刻整个逻辑才真的串起来，不再是抽象的概念。

如果没出来，Postgres 日志会告诉你哪一步断了，通常很具体。

## 做完之后想清楚的事

让我意外的是，整个流程对顺序的依赖比我想的强——不只是步骤要对，还要顺序对、权限对、用哪个用户跑对。每一步出错都不会大声报错，它只是悄悄失败，然后下一步继续跑，好像什么都没发生。

让我低估的是 `recovery.conf`。它不是普通的配置文件，它是模式选择开关。Postgres 启动时读它，决定自己是备库还是主库。有意删掉它来做 failover 提升：对，这就是设计行为。无意中删掉：你现在有两个独立的主库在向同一个应用写数据。文件名完全看不出它承载了多重的语义。

trigger file 让我想明白了另一件事。生产环境没人直接用这个切换——Patroni 和 repmgr 都自动处理 failover。但那些工具是建在这个原语上面的，理解了这个，我才能真正读懂它们的文档，而不只是照着操作。

这套 Vagrant 环境在跑通之后一周就删掉了。后来真的跟基础设施团队谈生产高可用的时候，我不需要别人给我解释什么是 WAL 段，什么是 `max_wal_senders`。这个框架已经在脑子里了。那个周末花得值。
