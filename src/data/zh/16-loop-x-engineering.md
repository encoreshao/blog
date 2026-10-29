---
title: "LoopX：住在我 Mac 里的安静同事，替我过一遍 issue、邮箱和简报"
date: 2026-10-10
tags: [AI, DevEx, Automation, Product]
excerpt: "Claude co-worker 好用，但算完账发现不划算，于是我搭了 LoopX：一位安静的同事，替我处理 GitLab issue、邮箱和每日简报，我只把注意力留给真正需要判断的事。"
draft: false
---

一边开着 Claude 的 co-worker 介绍页面，一边开着团队的 GitLab issue 积压列表。那个介绍页写的正是我想要的东西：每天早上自动把队列过一遍，能修的修掉，修不了的标出来，这样没人会让分配给自己的 issue 一直晾在那儿。我之前在 Slack 里已经见识过 Claude Tag 做类似的事，确实好用。然后我按团队实际产生的 GitLab 流量算了一下账，发现跟每台机器上已经在跑的 Claude Code 订阅比起来，这笔钱花得不值。

这件事让我一直惦记着。我想要的能力其实不复杂：列出分配给我的 issue，一个一个处理，能修的修，不用改代码的就回复，最后给我发一份摘要。这几步 `claude -p` 在终端里本来就能做。真正要额外付费的，是围绕它的调度、安全边界和仪表盘。于是我在已经付费的 CLI 之上，自己把这一层搭了出来。

第一版是一堆 Python 脚本加一个 `loops.json`。能用，然后越长越大。现在它叫 LoopX：一个 Mac 应用，核心用 Rust 写，带仪表盘，我机器上跑着六个 loop，还有一间 3D 办公室。

## LoopX 是什么

![LoopX 仪表盘：侧边栏的 Loops 下列着 GitLab、Topic Monitor、Inbox Triage、Daily Digest、RSS Watch 和 Meeting Prep，中间是 “Into the Loop” 输入框，提示语是 “Ask the loop anything, or paste a GitLab issue link”](https://raw.githubusercontent.com/encoreshao/loop-x/main/assets/screenshots/dashboard.png)

LoopX 是一个本地优先的 AI agent 编排层。一个 loop 就是一条独立的工作流，有自己的任务说明、调度时间和运行历史。真正动脑的 agent 是你指定的那个编码 CLI：默认是 Claude Code，也可以在设置里换成 Codex、Gemini、Kimi 或 Cursor。LoopX 负责决定什么时候跑、怎么跑，并把一件事从"发现任务"一路带到一个人类可以审阅的结果。

所有东西都留在这台 Mac 上。token 存在 Keychain 里，调度器是后台守护进程，没有任何东西托管在别处。安装可以用一条 `curl` 脚本、Homebrew，或者把 DMG 拖进应用程序，装完先跑一遍 `loopx doctor`，缺什么它会告诉你，然后再放心地给它排上日程。

## 关于 Loops

![Loops 页面：GitLab（工作日 10:00）、Topic Monitor（每天 10:00）、Inbox Triage（工作日 09:00）、Daily Digest（工作日 10:30）、RSS Watch（每天 00:00），每一项都有开关和 Edit schedule 链接](https://raw.githubusercontent.com/encoreshao/loop-x/main/assets/screenshots/loops.png)

主力依然是 GitLab issue 处理。每个工作日上午十点，它列出我在已配置项目里被分配的 issue，一个一个处理，绝不并行。这点我花了点时间才习惯，因为用 agent 干活的本能反应总是"为什么不开几个并行跑"。对每个 issue，它只做三件事里的一件：在独立的 `loop/issue-<iid>` 分支和隔离的 worktree 里修好，项目自己的 lint 和测试都通过之后才开合并请求；不需要改代码的，直接评论回答；需求不清楚的，打上 `loop:needs-human` 标签，向我提问。

其余几个都是从同一类问题里长出来的。Inbox triage 给新邮件打标签，对紧急的起草回复，从不发送。话题监控让我用一句话描述想盯的话题，每天发一份简报，哪天没有新东西，也会发一句"今天没什么新东西"，因为一个该出声却沉默的 loop，和一个坏掉的 loop 从外面看没有区别。

Daily digest 是我的早晨简报：待办、分配给我的 issue、等我 review 的合并请求、今天的会议，还有 LoopX 昨天干了什么。RSS watch 按我的兴趣给新内容排序，未读数字不会再往四位数爬。Meeting prep 会前根据议程、相关工作和参会人的近期邮件生成简报，周期性会议还会附上上次没收尾的事项。

还有几个我没打开的开关：给合并请求做预审并留下草稿的 MR review、诊断失败 CI 的 pipeline doctor、每周一次的陈旧工作清单、根据上个 tag 之后的合并请求写发布说明，以及 LinkedIn autopilot。默认只开 GitLab 和话题监控。README 的建议是一次只多开一个，先在 Runs 页面观察，再开下一个。我同意。

## 一切也都是命令

仪表盘是用来看的，`loopx` 命令是用来查的。它和 Mac 应用用的是同一个 Rust 二进制，所以终端和界面读的是同一份状态。

```bash
loopx doctor                 # 首次启动检查，包括调度器的心跳
loopx scheduler status       # 上次 tick、排队和运行中的任务、每个 loop 的下次运行时间
loopx loops                  # loop 注册表：名称、调度、入口
loopx ai-cli                 # 所有 loop 调用的是哪个 CLI（claude、codex、gemini、kimi、cursor）
loopx issues list            # 分配给你的、跨已跟踪项目的 GitLab issue
loopx run gitlab-loop        # 立即跑一个 loop
loopx run gitlab-loop <alias> <iid>   # 只处理某一个 issue
loopx serve                  # 仪表盘后端
```

`loopx scheduler status --json` 在出问题时会以状态码 1 退出，可以直接塞进 cron 检查或者 shell 提示符。超过三分钟没写心跳的 tick 会被判定为停摆。"它到底有没有在跑"，一条命令就能回答，什么都不用打开。

loop 底下还有一组用来查账的命令：`loopx ledger`、`loopx events`、`loopx metrics`、`loopx cost`、`loopx risk` 读取只追加的事件日志，`loopx loop eval --golden` 会在我改 prompt 前后，拿合成的 issue 去跑真实的 agent 做对比。状态都放在 `~/.loopx` 下，是可以直接读的普通文件。

## 无人值守，一个一个来

所有 loop 都由调度器自动触发。调度器每分钟 tick 一次，把到点的 loop 排进队列，再由一个 worker 一个一个地处理，所以 loop 之间不会抢同一台机器和同一个仓库。没有哪一步在等我点按钮，这也是为什么边界和任务本身一样重要。

LoopX 从不合并。它停在一个打开的合并请求上，合并永远是人点一下鼠标。它从不发邮件，也从不删除或移动邮件。它只碰我列出的项目。验证失败就升级，不会无限重试。

其中我最想为之辩护的一个决定：agent 会自己摸清每个项目的安装、lint 和测试命令，并记录在 issue 下面，但 loop 会在 gate 模式下把这些命令重新跑一遍，只有重跑通过才会开合并请求。模型说测试通过了，这只是一句待核对的话，所以由 loop 去核对。

另一个影响很大的拆分是成本。修代码需要 shell、worktree 和项目的测试套件；总结一份订阅或者日程，只需要对已经抓好的数据调一次模型。把这两类 loop 分开，对成本的影响比调 prompt 大，因为我每天大部分的量属于后一类。

## 然后我加了一间办公室

办公室是唯一没人要求的部分。它是一间用 three.js 做的 3D 场景，每个 loop 是坐在工位上的一位同事。加它的理由很简单：我整天盯着仪表盘、终端和 diff，想要一个看着舒服、也有点好玩的界面，缓解一下视觉疲劳。

![LoopX Office：夜晚的等距视角办公室，圆桌旁坐着标着 E1、E2、E3 的三位同事，旁边有休息区、LoopX 标志下的服务器机柜、左侧的书店，街上有行人，底部是 Auto、Dawn、Day、Dusk、Night 按钮](https://raw.githubusercontent.com/encoreshao/loop-x/main/assets/screenshots/office-mode.png)

loop 在跑，对应的同事就在干活。我在聊天里让它调用某个工具，对应的员工会走回自己的工位，调用失败就以琥珀色标出来。空闲的同事会在办公室里溜达，去隔壁的咖啡店或书店，街上有车和行人，光线随时间变化。Ctrl+V 可以在办公室和仪表盘之间切换。

它还顺带干了件实事：看一眼有人在敲键盘的屋子，就知道 agent 在干活，比读状态标签快。要紧的事我仍然在仪表盘里看，办公室是我一直开着这个应用的原因。

## 真正变了的东西

我一开始以为自己在挑的产品是"一个帮你处理 issue 的 AI"。后来发现不是，调用模型这一步从来都不是稀缺资源，我本来就有，订阅费反正都付了。托管产品真正在卖的，是围绕那次调用的编排：调度、边界、可见性，还有"无人值守的 agent 能碰什么"这套规则。这是个真实的产品，收费也合理，但它的每一块都是我自己也能做的决定。

变化最大的是我的工作方式。一个新 issue 出现，不管是谁提的，LoopX 都会自己接手：分析问题，判断要不要改代码，需要的话不用我开口就开始修。我不需要启动任何东西，只管打开结果，看它是不是符合我的预期。我的工作从做第一遍，变成了评判最后一遍，这样的一天和以前不一样。

另一个没想到的是，任务本身在代码库里占的比例有多小。修一个 issue、写一份简报，大多只是把一份任务说明交给 agent。每次运行的账本、预算上限、验证器、升级规则，还有那份"绝对不许做"的清单，才是项目的主体，而且我加的每一个 loop 都是如此。要是重来一遍，我会先写边界。LoopX 以 MIT 协议开源在 [github.com/encoreshao/loop-x](https://github.com/encoreshao/loop-x)。
