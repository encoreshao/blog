---
title: "github-trending：从一个定时脚本到 React 应用"
date: 2026-06-13
tags: [Open Source, API, React, DevEx]
excerpt: "我想每周追踪 GitHub 上快速上升的项目，不想靠手动刷页面。一个 Node.js 脚本最后变成了一个完整的 React 应用——记录这个过程。"
draft: false
---

每周一早上，我会打开 GitHub 的 Trending 页面，快速扫一眼，试图分辨哪些是新上来的，哪些只是老面孔。但那个页面把今天、本周、本月的内容混在一起，没有筛选，没有导出，也没有跨时间对比的方法。这样记了几个月，我开始不相信自己的记忆了，于是开始把数据写下来。

最初的版本是十几行 JavaScript。

```js
const response = await axios.get('https://api.github.com/search/repositories', {
  headers: { Authorization: `token ${GITHUB_TOKEN}` },
  params: {
    q: 'created:>=' + getLastWeekDate(),
    sort: 'stars',
    order: 'desc',
    per_page: 20,
  },
});
```

核心就是这段。GitHub Search API 支持 `created:>=` 限定符，可以查出过去七天内创建的仓库，按 star 数倒序排列。这不完全等同于 GitHub 自己定义的"trending"，但足够用——一个仓库在上线第一周就涨到几百 star，就是值得关注的项目。

脚本把结果存到 `docs/YYYY/MM/date.json`，同时生成一份 CSV，然后我设了个 cron job，每周日晚上自动跑。

```bash
0 21 * * 0 cd /path/to/github-trending && node index.js
```

这套流程跑了大概三个月。本地积累了一堆 JSON 文件，我用 VS Code 打开搜索。不好用。想比较一月和三月的趋势，就得手动 diff 文件。

## UI 变成了必需品

数据采集的问题解决了，怎么看数据还没解决。

我做 React 应用，主要是需要两个功能：一个可以排序的数据表格，以及不用写 grep 命令就能按语言或 topic 过滤。Ant Design 5 把大部分表格工作都包了，`Table`、`Input`、`Select` 这些标准组件直接用就行。真正有意思的 UI 问题是双视图模式。

开发者和研究者用这份数据的方式不一样。开发者想快速扫描、找到感兴趣的项目，需要卡片视图——仓库名、描述、star 数，一次看一个，点进去看详情。研究者或分析师想同时对比大量仓库，需要紧凑的表格，把二十多个字段都铺出来。我把两种视图都做了，底层用同一份数据，用户自己切换。

```
卡片视图  → 视觉浏览，一个仓库一张卡
表格视图  → 数据分析，所有字段可见，支持排序和筛选
```

可以展示的字段涵盖 GitHub API 返回的完整信息：仓库名、所有者、头像、描述、topics、许可证、各种 URL 变体、创建/更新/push 时间、star 数、fork 数、open issues、代码体积、主要语言，二十多个属性。大多数人用其中六个左右。

## API 限频的问题

GitHub Search API 未认证的情况下每小时只有 10 次请求。用 Personal Access Token 并开放 `public_repo` 权限，可以提升到每小时 30 次，但在分页翻数据的场景下还是不够用。

最初的做法是页面加载时直接全量拉取。结果当天就被同事的频繁访问触发了限频。修复分两步：在客户端用 `localStorage` 做好缓存，以及在触发限频时明确给出提示，而不是静默返回空结果。

Settings 面板把 token、展示字段的选择、每页条数都存在 `localStorage` 里，不走服务端。token 不离开浏览器。这是有意为之的设计——我不想为了代理 GitHub API 再维护一个后端，也不想让用户把 token 交给我的服务器去保管。

## 真正花时间的地方

查询的设计改了好几版。

最初用的是 GitHub 自己的 trending 接口。但那个接口不在官方 API 里，是直接抓页面的——接口路径会不定期变动，访问频率稍高就会被屏蔽。我早期版本就翻车过，GitHub 悄悄改了页面结构，脚本直接挂掉了。

改成 Search API 加 `created:>=YYYY-MM-DD` 之后稳定多了，但衡量的东西变了。一个两年前创建、最近突然火起来的仓库不会出现在结果里。这个取舍我考虑了一下，接受了。这个工具的目的是发现新东西——新冒出来快速上升的项目——不是监控已有仓库的突发热度。

导出格式比我预期的有用。我以为 JSON 够用了。后来 PM 要表格。用 `papaparse` 做 CSV 导出花了一个下午，之后每个月少接四个"能帮我把这个导出来吗"的消息。

## 现在的状态

Web 应用跑在 [github.ranbot.online](https://github.ranbot.online)。cron 脚本每周日还在跑。`docs/` 目录里已经积累了近两年的周快照，我一直打算把这些数据做成更有意思的东西——趋势曲线、语言分布的变化之类——但一直没排上。

这个项目起点不是一个清晰的需求，而是我对一个重复手动操作的厌烦。那往往是最值得做的工具的起点。
