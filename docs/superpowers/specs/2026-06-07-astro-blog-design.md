# Astro Blog Design Spec
**Date:** 2026-06-07
**Author:** Encore Shao (encore@ekohe.com)

---

## Overview

A personal blog for Encore Shao (邵壮) — Full-stack Engineer & AI Researcher at Ekohe, Shanghai. Built with Astro, deployed to a self-hosted server at `blog.icmoc.com`. Bilingual (English + Chinese). Visual direction: Glass & Glow with a Timeline layout.

---

## Visual Design

**Theme:** Glass & Glow
- Background: deep space gradient (`#1a1a2e → #16213e → #0f3460`)
- Ambient radial glows: cyan (`#00d4ff`) top-right, purple (`#a855f7`) bottom-left
- Cards: `rgba(255,255,255,0.05)` background, `rgba(255,255,255,0.08)` border, `border-radius: 12px`
- Glassmorphism nav: `backdrop-filter: blur(16px)`, sticky

**Typography:** System UI stack (`-apple-system, BlinkMacSystemFont, 'Segoe UI'`)

**Color palette for tags:**
- AI / MCP: cyan `#00d4ff`
- Ruby / Open Source: purple `#a855f7`
- Chrome extensions: blue `#60a5fa`
- Rails / Backend: orange `#fb923c`
- Product: green `#34d399`

**Layout:** Timeline + Tags
- Sticky nav (logo left, links center, EN/中文 switcher right)
- Page header: "Writing" title + subtitle
- Tag filter row (pill buttons, single-select)
- Vertical timeline: gradient line left, colored dot per post, cards stacked with hover slide effect
- Year separator labels in timeline
- Footer with GitHub + icmoc.com links

---

## Tech Stack

| Layer | Choice |
|---|---|
| Framework | Astro 5.x, `output: 'static'` |
| Styling | Tailwind CSS 4.x + CSS custom properties for Glass & Glow theme |
| Content | Markdown (`.md`) via Astro Content Collections |
| i18n | Astro built-in i18n routing, `defaultLocale: 'en'`, locales: `['en', 'zh']` |
| Build output | `dist/` directory |
| Node | 20+ |

---

## Project Structure

```
blog/
├── src/
│   ├── content/
│   │   ├── config.ts              ← content collection schema
│   │   └── blog/
│   │       ├── en/                ← English .md posts
│   │       └── zh/                ← Chinese .md posts
│   ├── pages/
│   │   ├── index.astro            ← redirects to /en/
│   │   ├── en/
│   │   │   ├── index.astro        ← timeline homepage (EN)
│   │   │   └── [slug].astro       ← post page (EN)
│   │   └── zh/
│   │       ├── index.astro        ← timeline homepage (ZH)
│   │       └── [slug].astro       ← post page (ZH)
│   ├── components/
│   │   ├── Nav.astro              ← sticky nav + lang switcher
│   │   ├── TimelineFeed.astro     ← timeline list with year separators
│   │   ├── PostCard.astro         ← individual glass card
│   │   └── TagFilter.astro        ← pill filter row (client:load)
│   ├── layouts/
│   │   ├── Base.astro             ← HTML shell, meta tags
│   │   └── BlogPost.astro         ← post page layout
│   └── styles/
│       └── global.css             ← Glass & Glow CSS vars, base reset
├── public/
│   └── favicon.svg
├── astro.config.mjs
├── tailwind.config.mjs
├── tsconfig.json
├── deploy.sh                      ← build + rsync wrapper
└── nginx.conf.example             ← nginx server block for blog.icmoc.com
```

---

## Content Collections Schema

Each post frontmatter:

```yaml
---
title: "Building bamboohr-mcp: An MCP Server for HR APIs"
date: 2026-06-01
tags: [AI, MCP]
lang: en
excerpt: "I wanted to let any LLM talk to BambooHR's API..."
draft: false
---
```

Fields: `title` (string), `date` (Date), `tags` (string[]), `lang` (en|zh), `excerpt` (string), `draft` (boolean, default false).

---

## i18n Routing

- `/` → redirects to `/en/`
- `/en/` → English timeline homepage
- `/en/[slug]` → English post
- `/zh/` → Chinese timeline homepage
- `/zh/[slug]` → Chinese post
- Language switcher in nav links to the same slug in the other locale (falls back to homepage if translation missing)

---

## Article Plan (16 posts — 8 topics × 2 languages)

| # | Title (EN) | Tags | Source |
|---|---|---|---|
| 1 | Building bamboohr-mcp: An MCP Server for HR APIs | AI, MCP | `bamboohr-mcp` repo |
| 2 | china_regions: Lessons from a 25-Star Ruby Gem | Ruby, Open Source | `china_regions` repo |
| 3 | AI-Powered Bookmark Dashboard: A Chrome Extension Story | AI, Chrome | `bookmark-dashboard` repo |
| 4 | Agentic AI in Production: What I Learned Building RanBot | AI, Agents | icmoc.com + RanBot |
| 5 | 10 Years of Rails: What I Still Reach For Every Day | Ruby, Rails | personal experience |
| 6 | Building TrendShop: When AI Meets Fashion Discovery | AI, Product | icmoc.com |
| 7 | Crunchbase API in Ruby: A Library Worth Building | Ruby, API | `crunchbase-ruby-library` repo |
| 8 | WorkflowPro: Automating Office Work with Rails | Rails, Product | icmoc.com |

Each article: 800–1200 words, experience-first voice (not tutorial-first), no dry docs style.

---

## Deploy Workflow

```bash
# deploy.sh
#!/bin/bash
set -e
npm run build
rsync -avz --delete dist/ user@yourserver:/var/www/blog/
echo "Deployed to blog.icmoc.com"
```

**Nginx config** (example block included in repo as `nginx.conf.example`):
```nginx
server {
    listen 80;
    server_name blog.icmoc.com;
    root /var/www/blog;
    index index.html;
    location / {
        try_files $uri $uri/ $uri.html =404;
    }
}
```

DNS: A record for `blog.icmoc.com` → server IP.

---

## Out of Scope

- CMS or admin UI — markdown files edited directly
- Comments system — no comments in v1
- Search — not in v1
- RSS feed — can add post-launch as a single Astro endpoint
