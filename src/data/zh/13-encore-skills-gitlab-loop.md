---
title: "encore-skills：别再重复教你的 AI"
date: 2026-07-29
tags: [AI, DevEx, GitLab, Product]
excerpt: "同一套 GitLab 工作流，我在 Claude Code、Cursor、Codex 里各教了一遍，直到某天一个 MR 漏了 issue 编号——于是干脆做了一个三端共用的技能库。"
draft: false
---

那是个周五下午,我开着三个终端。Claude Code 对着一个客户的仓库,Cursor 开着另一个项目,Codex 接在第三个项目的 CI 里。三边干的是同一件事:读一个 GitLab issue,找根因,切分支,修复,自查,开 MR。这套流程的说明我写了三遍,三种格式——一份 `CLAUDE.md`,一堆 `.cursor/rules/*.mdc`,一份 `AGENTS.md`——因为每个工具都要求自己那套格式的流程定义。

那周我改了 MR 标题的规范,要求必须带 issue 编号:`fix: #482 nil check on webhook payload`,而不是光写 `fix: nil check on webhook payload`。我更新了 `CLAUDE.md`,却忘了改 Cursor 那份规则。三天后一个 MR 发出去,标题里没有 issue 编号,那个项目的 reviewer 问了一句"这个关联哪个 ticket"。事情不大,但这正是同一套流程散落在三个地方、只有一份是最新的时候会出的问题。

## 真正动手做的事

解法不是"下次小心点",而是不再维护三份同样的流程。`skills/` 成了唯一的真相来源——每个技能一份 `SKILL.md`,纯 markdown 加 frontmatter,不带任何工具专属语法。然后三个适配器:

```bash
./scripts/setup-claude.sh   # 软链接到 ~/.claude/skills/
./scripts/setup-cursor.sh   # 生成 .cursor/rules/*.mdc
./scripts/setup-codex.sh    # 生成 AGENTS.md
```

改一次技能,重新生成适配器,两边一起提交。这个仓库自己也在吃自己的狗粮——它自己的 `CLAUDE.md`、`AGENTS.md`、`.cursor/rules/` 都是从自己的 `skills/` 目录生成的,所以不管我用哪个工具在维护这个技能库,用的都是它自己产出的技能。

由此拆出十个技能,分两条循环。

## 两条循环

第一条给 PM 和设计师用,全程不需要碰代码库:

```
write-issue → share → gather-feedback → refine → validate → finalize
      ↑                      |
      └───────── iterate ────┘
```

`write-issue` 把一个粗糙的想法整理成结构化的 GitLab issue。剩下的交给 `pm-workflow`——发出去、收集用户和相关方的反馈、修改、验证,没到位就回头再迭代一轮。真正的完成标准是"开发者接手不用反问一句就能开工",不是"issue 有标题有描述"。

第二条就是那个让我踩了 MR 标题坑的循环:

```
write-issue → analyze-issue → fix-issue → review-code → create-mr → [merge]
      ↑                                                                 |
      └──────────────────────── new issue from feedback ────────────────┘
```

`eng-workflow` 把这条循环跑成一个连贯的会话,一个阶段一个阶段来,每个阶段都有一个必须先满足的门槛:写代码之前先找到根因,收工之前先确认问题真的没了(不只是测试变绿),`create-mr` 跑之前先给出"可以合并"的结论且没有遗留阻塞项,MR 开出去之前先确认目标分支是你真正切出来的那条。`summarize-issue` 和 `triage-issue` 不在主循环上,而是挂在旁边——一个在 MR 已经存在之后发一份复盘,另一个负责回复一个已经在跑的 issue 上的评论。

## 安装

技能都放在一个仓库里,靠一个安装脚本按工具适配:

```bash
# Claude Code —— CLI、桌面版、IDE 插件通用
curl -fsSL https://raw.githubusercontent.com/encoreshao/encore-skills/main/scripts/setup.sh | bash -s -- --claude

# Cursor —— 在你想装的项目目录里跑
cd /your/project
curl -fsSL https://raw.githubusercontent.com/encoreshao/encore-skills/main/scripts/setup.sh | bash -s -- --cursor

# Codex —— 同样在项目目录里跑,生成 AGENTS.md
cd /your/project
curl -fsSL https://raw.githubusercontent.com/encoreshao/encore-skills/main/scripts/setup.sh | bash -s -- --codex
```

不管装给哪个工具,这几条一行命令都会自己把仓库克隆(或更新)到 `~/.encore-skills`,不用单独跑一遍 `git clone`。以后想升级,原样再跑一次同样的命令就行。

## 配一次 GitLab,一劳永逸

所有跟 GitLab 打交道的技能读的都是同一份配置,所以这件事一台机器只用做一次。装完重启 Claude Code 之后:

```
/gitlab-config
```

它会引导你填入 GitLab 实例地址和一个带 `api` 权限的个人访问令牌。在 Cursor 或 Codex 里没有斜杠命令这一层,直接用大白话说就行——"跑一下 gitlab-config 技能,帮我配置 GitLab 访问"。多个 GitLab 实例(公司自建一个,side project 用 gitlab.com 一个)可以在同一份配置文件里用不同名字并存,每个技能会根据你所在的项目自动选对。

## 怎么用

日常用起来更像是"说你手头有什么",而不是"运行一个工具"。进到一个有未处理 issue 的项目,直接说"分析一下这个 issue",或者 `/eng-workflow #482`——技能会自己从上下文判断你是从头开始,还是接着一半的循环往下走。同一句话在 Claude Code、Cursor、Codex 里都能用,因为三个工具底层读的是同一份技能定义文件,不一样的只是外面那层读它的壳。

## 最费时间的那部分

`create-mr` 最简单的版本会默认所有分支都指向 `main`。这在团队从 `staging` 或 `develop` 切分支时立刻就崩了,这种情况在客户项目里常见到我在吃自己狗粮的第一周就撞上了。这个修复牵涉两个技能,不是一个:`fix-issue` 在切出 `<type>/<issue-number>-<func-name>` 之前先记下当时所在的分支,`create-mr` 再把这个信息读回来,把 MR 指向那个分支,而不是瞎猜 `main`。这个问题单靠哪个技能自己都解决不了——信息必须在两者的交接之间活下来,这跟任何一个技能自身的逻辑都是两码事。

另一个我低估了的地方是记忆。`analyze-issue` 和 `triage-issue` 都需要知道一个 GitLab 项目的一些信息——谁在这个项目里、一个 issue 的评论历史长什么样、上次分析类似问题时我得出了什么结论。没有缓存的话,每次运行都要重新拉取、重新推导一遍,不仅慢,更糟的是一小时前那条评论线索,不会自动进到我现在正在起草的回复里。于是 `gitlab-config` 长出了一个本地缓存,放在 `~/.gitlab/cache/` 下,按实例、group、项目、issue 分层。`sync-issue` 命令依然每次都会调用 GitLab API——新评论不会漏掉——但会按 note id 合并到已有缓存上,而不是丢掉历史重来一遍。像 `acme/rocket` 这种 group 下挂着 `rocket-web` 和 `rocket-mobile` 两个项目,团队名单只同步一次,两个项目共用,不用各拉一遍。

## 亲眼看它跑起来的那一刻

真正让我确信这套东西能用的,不是一次演示,而是拿 `triage-issue` 跑一个有十一条评论的真实 issue,大部分评论根本不是冲我来的。这个技能准确挑出了两条 @我 的评论,略过了另外两个工程师之间跟我无关的来回讨论,而且草拟的回复是扎根在代码当前实际状态上的——不是猜的,是真的去读了评论里提到的那个文件。我本来预计要花二十分钟修改草稿,结果只改了两分钟,大部分时间还在调一句话的语气。

另一件事更小,但印象更深。`create-mr` 翻到 issue 的评论线索,找到三周前一条评论,链接着一个已经解决了一半问题的相关 MR,于是在描述里加了一段"Related",把这条线索指给 reviewer 看。我没让它去找这个。它是因为技能说要读评论线索才读的,顺手发现了一个我自己都得靠回忆才能想起来的东西。

## 真正变了的东西

一开始我以为难点是让 AI agent 写出正确的代码、开出干净的 MR。事实证明这部分反而是容易的——三个工具都完全能照着一份写得好的流程走下去。真正的问题是,我从来没把这套流程写成一种能在工具之间原样搬运的形式。"怎么开 MR"、"什么时候该回复评论"这些规则的每一次调整,都只存在我脑子里,当天用哪个工具就敲进哪个工具,不出一周就跟另外两边对不上了。

一份 `SKILL.md` 逼着你把流程写得足够明确才能搬得动,搬得动才能做到改一次、处处生效。这比"AI 帮你写代码"要小得多,但也是拿去客户项目上真跑了一个月之后,唯一站得住的那个想法。`encore-skills` 在 GitHub 上:[github.com/encoreshao/encore-skills](https://github.com/encoreshao/encore-skills),MIT 协议,带安装脚本。
