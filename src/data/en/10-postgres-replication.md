---
title: "Setting Up PostgreSQL 10 Streaming Replication the Hard Way"
date: 2026-06-19
tags: [PostgreSQL, Infrastructure, DevEx]
excerpt: "What it actually takes to get Postgres streaming replication working between two local VMs — without skipping the parts that matter."
draft: false
---

The team had one Postgres instance. No replica. No failover. Just one server doing everything, and everyone pretending that was fine.

Nobody was lying exactly. We had backups. We had a plan. The plan was "restore from backup if the server dies" — which meant downtime measured in hours, not minutes. That kind of plan sounds reasonable until you're the one executing it at 2am.

I wanted to understand replication before I was in a position where I needed to urgently. So I spun up two VirtualBox VMs with Vagrant — Ubuntu 18.04, PostgreSQL 10 — and spent a weekend on it.

## The Setup

Two machines, two IPs:

- Master: `192.168.33.11` — takes reads and writes
- Slave: `192.168.33.22` — read-only standby, follows the master's WAL stream

Vagrant made this easy to tear down and start over, which I did more than once. The Vagrantfile is three lines once you strip out the comments:

```ruby
config.vm.box = "ubuntu/bionic64"
config.vm.network "private_network", ip: "192.168.33.11"
config.vm.hostname = "pg-master"
```

Same for the slave, different IP and hostname.

## Configuring the Master

Every change on the master — insert, update, delete — gets written to the WAL before it touches the actual data files. That log exists for crash recovery. It's also the stream the slave subscribes to. Your job on the master is to expose it and give the slave permission to read it.

Start by creating a replication user:

```sql
CREATE ROLE replicate WITH REPLICATION LOGIN PASSWORD 'your-password';
```

Then edit `/etc/postgresql/10/main/postgresql.conf`:

```conf
listen_addresses = '*'
wal_level = replica
max_wal_senders = 3
wal_keep_segments = 64
```

`wal_level = replica` is the key one. Without it, Postgres won't generate the WAL data needed for streaming replication. `max_wal_senders` caps how many slaves can connect. `wal_keep_segments` controls how many WAL segments to keep around — enough runway for the slave to catch up if it falls behind.

The other file that trips people up is `pg_hba.conf`. You need to explicitly allow the slave to connect for replication:

```conf
host    replication     replicate    192.168.33.22/32    md5
```

That line has to use `replication` as the database name, not `all` or your app database. It's a special keyword Postgres uses for replication connections. Miss it, and the slave connection fails with a cryptic auth error that gives you almost no signal about what went wrong.

Restart Postgres on the master after both config changes.

## Configuring the Slave

This is where most tutorials lose me. They tell you to "set up the slave" like it's two steps. It's not.

First, stop Postgres on the slave:

```bash
sudo service postgresql stop
```

Then delete the entire data directory:

```bash
rm -rf /var/lib/postgresql/10/main/*
```

You're not wiping data you care about — this is the empty directory Postgres created during installation. You're clearing space for the base backup that's about to come from the master.

Set the permissions back:

```bash
chmod 700 /var/lib/postgresql/10/main
chown postgres:postgres /var/lib/postgresql/10/main
```

Now run `pg_basebackup` as the postgres user:

```bash
sudo -u postgres pg_basebackup \
  -h 192.168.33.11 \
  -D /var/lib/postgresql/10/main/ \
  -P -U replicate \
  --wal-method=stream
```

This copies the entire master data directory to the slave, including a consistent snapshot of the WAL position at the time of backup. The `-P` flag shows progress. It'll take a few seconds for a fresh install, longer in production.

After the backup, create `/var/lib/postgresql/10/main/recovery.conf`:

```conf
standby_mode = 'on'
primary_conninfo = 'host=192.168.33.11 port=5432 user=replicate password=your-password'
trigger_file = '/tmp/MasterNow'
```

`standby_mode = 'on'` tells Postgres to stay in recovery mode and keep following the WAL stream instead of completing recovery and becoming a standalone primary. `trigger_file` is the failover mechanism — create that file on the slave and it stops following the master and promotes itself.

Start Postgres on the slave:

```bash
sudo service postgresql start
```

## Verifying It Works

Start with the connection check. On the master:

```sql
SELECT * FROM pg_stat_activity WHERE usename = 'replicate';
```

One row means the slave connected and the stream is live. No rows means the slave never got through — go back to `pg_hba.conf`. That's where I had the wrong entry on my first attempt, and the auth error from the slave gave almost no hint why.

Once the connection is up, the real test is a write. Create a database on the master:

```sql
CREATE DATABASE replication_test;
```

Then connect to the slave:

```sql
SELECT datname FROM pg_database WHERE datname = 'replication_test';
```

It was there within a second. Everything I'd configured — the WAL level, the replication role, the base backup, the recovery.conf — reduced to one row appearing on a different machine. That's the moment the mental model stops being abstract.

If it doesn't appear, the Postgres logs on both machines are specific enough to tell you exactly which step failed.

## What I Took Away

What surprised me was how much the sequence depends on each step being exactly right — not just correct, but in the right order, with the right permissions, as the right user. None of the steps fail loudly. They fail quietly, and the next step proceeds as if nothing happened.

The piece I'd underestimated was `recovery.conf`. It's not configuration — it's mode selection. Postgres reads it at startup and decides whether to behave as a standby or a primary. Delete it on a standby you want to promote: that's failover, working as designed. Delete it by accident and you have two independent primaries writing to the same application. The file carries none of that weight in its name.

The trigger file taught me something different. In production nobody touches it directly — Patroni and repmgr handle failover automatically. But they're built on top of this primitive, and understanding it meant I could read their documentation instead of just following it.

I deleted the Vagrant setup a week after I got it working. When the infrastructure team conversation eventually happened, I didn't need anyone to explain WAL segments or `max_wal_senders`. I already had a frame for it. That saved more time than the weekend cost.
