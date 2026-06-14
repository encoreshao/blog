# 邵壮的个人博客

> Also available in: [English](README.md)

[邵壮（Encore Shao）](https://icmoc.com)的个人博客，上海全栈工程师 & AI 研究员。基于 Astro 6 构建，使用 Tailwind CSS 4 和 Glass & Glow 暗色主题，支持中英双语。

线上地址：**[blog.icmoc.com](https://blog.icmoc.com)**

---

## 技术栈

| 层次 | 技术 |
|------|------|
| 框架 | [Astro 6](https://astro.build)（静态输出） |
| 样式 | [Tailwind CSS 4](https://tailwindcss.com)，通过 `@tailwindcss/vite` 接入 |
| 内容 | Markdown + Astro Content Layer API |
| 语言 | TypeScript（严格模式） |
| Sitemap | `@astrojs/sitemap` — 构建时自动生成 |
| RSS | `@astrojs/rss` — 中英双语 Feed，构建时自动更新 |
| 部署 | `rsync` 到自托管服务器 |

---

## 环境要求

- **Node.js ≥ 22.12.0**（推荐使用 [nvm](https://github.com/nvm-sh/nvm) 管理版本）
- npm ≥ 10

```bash
# 使用 nvm 切换版本
nvm install 22
nvm use 22
```

---

## 本地开发

```bash
# 1. 克隆仓库
git clone https://github.com/encoreshao/blog.git
cd blog

# 2. 安装依赖
npm install

# 3. 启动开发服务器
npm run dev
```

开发服务器运行在 **http://localhost:4321**，保存文件后自动刷新。

| 命令 | 说明 |
|------|------|
| `npm run dev` | 在 `localhost:4321` 启动开发服务器 |
| `npm run build` | 构建生产版本到 `dist/` |
| `npm run preview` | 在本地预览生产构建结果 |

---

## 项目结构

```
blog/
├── src/
│   ├── data/
│   │   ├── en/          ← 英文文章（.md）
│   │   └── zh/          ← 中文文章（.md）
│   ├── components/      ← Astro 组件（导航、目录等）
│   ├── layouts/         ← Base.astro、BlogPost.astro
│   ├── pages/
│   │   ├── index.astro  ← 重定向到 /en/
│   │   ├── 404.astro    ← 自定义 404 页（矩阵雨 + 故障特效）
│   │   ├── rss.xml.ts   ← 英文 RSS Feed
│   │   ├── en/          ← 英文页面
│   │   └── zh/          ← 中文页面（含 rss.xml.ts）
│   └── styles/
│       └── global.css   ← Glass & Glow 主题 + Tailwind
├── content.config.ts    ← 内容集合 Schema
├── astro.config.mjs
├── deploy.sh            ← 构建 + rsync 部署脚本
└── nginx.conf.example   ← 自托管服务器的 nginx 配置示例
```

---

## 写一篇新文章

1. 在 `src/data/en/` 下创建 Markdown 文件（如需中文版，同步在 `src/data/zh/` 下创建）。

2. 使用以下 frontmatter 格式：

```markdown
---
title: "文章标题"
date: 2026-01-15
tags: [Rails, AI]       # 一个或多个标签
excerpt: "在首页卡片上显示的一句话摘要。"
draft: false
---

正文内容...
```

3. 文件名即 URL slug。`09-my-post.md` → `/zh/09-my-post`

4. 可用标签：`AI`、`Rails`、`Ruby`、`MCP`、`Chrome`、`Open Source`、`Product`、`Agents`

5. **Sitemap 和 RSS 在每次 `npm run build` 时自动更新**，无需手动操作。

---

## 订阅 Feed

| Feed | URL | 说明 |
|------|-----|------|
| 英文 RSS | `/rss.xml` | 全部英文文章，按时间倒序 |
| 中文 RSS | `/zh/rss.xml` | 全部中文文章，按时间倒序 |
| Sitemap | `/sitemap-index.xml` | 完整站点地图（中英所有页面） |

每次构建时，RSS Feed 和 Sitemap 都会从内容集合自动重新生成。新增文章后只需运行 `npm run build` 即可。

---

## 部署

### 一键部署

```bash
./deploy.sh
```

脚本会先运行 `npm run build`，然后通过 rsync 将 `dist/` 同步到 `encore@blog.icmoc.com:/var/www/blog`。

### 自定义服务器地址或路径

```bash
# 通过位置参数
./deploy.sh user@yourserver.com /var/www/blog

# 或通过环境变量
DEPLOY_HOST=user@yourserver.com DEPLOY_PATH=/var/www/blog ./deploy.sh
```

### 脚本做了什么

1. 运行 `npm run build` → 生成 `dist/`
2. 执行 `rsync -avz --delete dist/ user@host:/remote/path`
   - `--delete` 会删除服务器上本地已不存在的文件
   - 增量传输：只上传变更的文件

### 服务器配置（nginx）

将 `nginx.conf.example` 复制到 nginx 配置目录，并按需修改路径：

```bash
# 在服务器上执行
sudo cp nginx.conf.example /etc/nginx/sites-available/blog.icmoc.com
sudo ln -s /etc/nginx/sites-available/blog.icmoc.com /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

用 Let's Encrypt 免费获取 TLS 证书：

```bash
sudo certbot --nginx -d blog.icmoc.com
```

### 首次服务器初始化

```bash
# 在服务器上创建 web 根目录（只需执行一次）
ssh encore@blog.icmoc.com "sudo mkdir -p /var/www/blog && sudo chown encore:www-data /var/www/blog"
```

---

## 文章列表

| # | 中文 | English |
|---|------|---------|
| 1 | 开发 bamboohr-mcp：让 AI 直接对话 HR 系统 | Building bamboohr-mcp: An MCP Server for HR APIs |
| 2 | china_regions：一个 25 Star Ruby Gem 的诞生 | china_regions: Lessons from a 25-Star Ruby Gem |
| 3 | AI 书签仪表盘：一个 Chrome 扩展的开发故事 | AI-Powered Bookmark Dashboard: A Chrome Extension Story |
| 4 | 生产环境中的 Agentic AI：RanBot 带给我的十二个月 | Agentic AI in Production: What I Learned Building RanBot |
| 5 | 写了十年 Rails：那些我至今每天都在用的东西 | 10 Years of Rails: What I Still Reach For Every Day |
| 6 | 构建 TrendShop：当 AI 遇上时尚发现 | Building TrendShop: When AI Meets Fashion Discovery |
| 7 | 为 Crunchbase API 开发一个 Ruby 封装库 | Building a Ruby Wrapper for the Crunchbase API |
| 8 | WorkflowPro：做一个真正被人用的企业自动化系统 | WorkflowPro: Building Office Automation That Actually Gets Used |
| 9 | github-trending：从一个定时脚本到 React 应用 | Building github-trending: From a Cron Script to a React App |

---

## 许可证

文章内容 © 邵壮（Encore Shao）保留所有权利。
主题代码（组件、样式）MIT 协议。
