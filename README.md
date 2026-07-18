# Encore Shao — Personal Blog

> Also available in: [中文](README.zh.md)

Personal blog for [Encore Shao](https://icmoc.com) — Full-stack Engineer & AI Researcher based in Shanghai. Built with Astro 6, Tailwind CSS 4, and a Glass & Glow dark theme. Bilingual: English and Chinese.

Live at **[blog.icmoc.com](https://blog.icmoc.com)**

---

## Stack

| Layer | Technology |
|-------|-----------|
| Framework | [Astro 6](https://astro.build) (static output) |
| Styles | [Tailwind CSS 4](https://tailwindcss.com) via `@tailwindcss/vite` |
| Content | Markdown with Astro Content Layer API |
| Language | TypeScript (strict) |
| Sitemap | `@astrojs/sitemap` — auto-generated at build time |
| RSS | `@astrojs/rss` — bilingual feeds, auto-updated at build time |
| Deploy | `rsync` to self-hosted server |

---

## Prerequisites

- **Node.js ≥ 22.12.0** (use [nvm](https://github.com/nvm-sh/nvm) to manage versions)
- npm ≥ 10

```bash
# If you use nvm
nvm install 22
nvm use 22
```

---

## Local Development

```bash
# 1. Clone the repo
git clone https://github.com/encoreshao/blog.git
cd blog

# 2. Install dependencies
npm install

# 3. Start the dev server
npm run dev
```

The dev server runs at **http://localhost:4321**. The site auto-reloads on file saves.

| Command | Description |
|---------|-------------|
| `npm run dev` | Start dev server at `localhost:4321` |
| `npm run build` | Build to `dist/` |
| `npm run preview` | Preview the production build locally |

---

## Project Structure

```
blog/
├── src/
│   ├── data/
│   │   ├── en/          ← English articles (.md)
│   │   └── zh/          ← Chinese articles (.md)
│   ├── components/      ← Astro components (Nav, TOC, etc.)
│   ├── layouts/         ← Base.astro, BlogPost.astro
│   ├── pages/
│   │   ├── index.astro  ← Redirects to /en/
│   │   ├── 404.astro    ← Custom 404 (matrix rain + glitch effect)
│   │   ├── rss.xml.ts   ← English RSS feed
│   │   ├── en/          ← English pages
│   │   └── zh/          ← Chinese pages (includes rss.xml.ts)
│   └── styles/
│       └── global.css   ← Glass & Glow theme + Tailwind
├── content.config.ts    ← Content collection schema
├── astro.config.mjs
├── scripts/
│   └── deploy.sh        ← Build + rsync deploy script
└── nginx.conf.example   ← Nginx config for self-hosted setup
```

---

## Writing a New Article

1. Create a Markdown file in `src/data/en/` (and optionally `src/data/zh/` for the Chinese version).

2. Use this frontmatter:

```markdown
---
title: "Your Article Title"
date: 2026-01-15
tags: [Rails, AI]       # one or more tags
excerpt: "One sentence that appears on the homepage card."
draft: false
---

Your content here...
```

3. The filename becomes the URL slug. `09-my-post.md` → `/en/09-my-post`

4. Available tags: `AI`, `Rails`, `Ruby`, `MCP`, `Chrome`, `Open Source`, `Product`, `Agents`

5. **Sitemap and RSS update automatically** on every `npm run build` — no manual step needed.

---

## Feeds & Sitemap

| Feed | URL | Description |
|------|-----|-------------|
| English RSS | `/rss.xml` | All English posts, newest first |
| Chinese RSS | `/zh/rss.xml` | All Chinese posts, newest first |
| Sitemap | `/sitemap-index.xml` | Full sitemap (all pages, both languages) |
| llms.txt | `/llms.txt` | Curated, LLM-friendly index of every article (EN + ZH) with links and descriptions |
| llms-full.txt | `/llms-full.txt` | Full text of every article (EN + ZH), inlined in one file, for AI agents that want the whole site in one fetch |

**All of these are generated automatically at build time — no manual step needed.**

- **RSS** (`/rss.xml`, `/zh/rss.xml`) — Astro API endpoints that query the content collections on every `npm run build`. Adding a new `.md` file is enough.
- **Sitemap** (`/sitemap-index.xml`) — powered by `@astrojs/sitemap`, configured in `astro.config.mjs`. It crawls all pages Astro renders and writes a sitemap index + per-language sitemaps. New articles appear automatically on the next build.
- **llms.txt / llms-full.txt** — Astro API endpoints (`src/pages/llms.txt.ts`, `src/pages/llms-full.txt.ts`) following the [llmstxt.org](https://llmstxt.org) convention, so AI agents and crawlers can quickly discover and understand the whole site. `robots.txt` explicitly allows major AI crawlers (GPTBot, ClaudeBot, Google-Extended, PerplexityBot, CCBot, etc.) and points them at `/llms.txt`.

---

## Deployment

### Quick deploy

```bash
./scripts/deploy.sh
```

### What the script does

1. Runs `npm run build` → produces `dist/` (always builds first — deploy never uses a stale build)
2. `rsync -avz --delete dist/ icmoc.com:/var/www/production/blog`
   - `--delete` removes files on the server that no longer exist locally
   - Incremental: only changed files are uploaded
   - Aborts immediately if the build fails (`set -e`)

### Server setup (nginx)

Copy `nginx.conf.example` to your nginx config directory and update the paths:

```bash
# On your server
sudo cp nginx.conf.example /etc/nginx/sites-available/blog.icmoc.com
sudo ln -s /etc/nginx/sites-available/blog.icmoc.com /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

Get a free TLS certificate with Let's Encrypt:

```bash
sudo certbot --nginx -d blog.icmoc.com
```

### First-time server prep

```bash
# Create the web root on your server (run once)
ssh blog.icmoc.com "sudo mkdir -p /var/www/blog && sudo chown encore:www-data /var/www/blog"
```

---

## Content

| # | English | Chinese |
|---|---------|---------|
| 1 | Building bamboohr-mcp: An MCP Server for HR APIs | 开发 bamboohr-mcp：让 AI 直接对话 HR 系统 |
| 2 | china_regions: Lessons from a Ruby Gem | china_regions：一个 Ruby Gem 的诞生 |
| 3 | AI-Powered Bookmark Dashboard: A Chrome Extension Story | AI 书签仪表盘：一个 Chrome 扩展的开发故事 |
| 4 | Agentic AI in Production: What I Learned Building RanBot | 生产环境中的 Agentic AI：RanBot 带给我的十二个月 |
| 5 | 10 Years of Rails: What I Still Reach For Every Day | 写了十年 Rails：那些我至今每天都在用的东西 |
| 6 | Building TrendShop: When AI Meets Fashion Discovery | 构建 TrendShop：当 AI 遇上时尚发现 |
| 7 | Building a Ruby Wrapper for the Crunchbase API | 为 Crunchbase API 开发一个 Ruby 封装库 |
| 8 | WorkflowPro: Building Office Automation That Actually Gets Used | WorkflowPro：做一个真正被人用的企业自动化系统 |
| 9 | Building github-trending: From a Cron Script to a React App | github-trending：从一个定时脚本到 React 应用 |
| 10 | Setting Up PostgreSQL 10 Streaming Replication the Hard Way | 用 Vagrant 搭建 PostgreSQL 10 主从复制 |

---

## License

Content (articles) © Encore Shao. All rights reserved.
Code (theme, components) MIT.
