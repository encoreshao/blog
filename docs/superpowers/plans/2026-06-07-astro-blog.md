# Astro Blog Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a bilingual (EN/ZH) personal blog for Encore Shao at blog.icmoc.com using Astro 5 with a Glass & Glow visual theme, timeline homepage, rich article pages, and rsync deploy to self-hosted server.

**Architecture:** Static Astro 5 site with two Content Collections (`en`, `zh`) for bilingual posts. Pages live in `src/pages/en/` and `src/pages/zh/`. All client interactivity (tag filtering, reading progress, TOC) uses inline Astro `<script>` tags. Built to `dist/`, deployed via `rsync`.

**Tech Stack:** Astro 5, Tailwind CSS 4 (`@tailwindcss/vite` Vite plugin), TypeScript (strict), Markdown, Node 20+

---

## File Map

```
blog/
├── astro.config.mjs
├── tsconfig.json
├── deploy.sh
├── nginx.conf.example
├── .gitignore
├── public/
│   └── favicon.svg
├── src/
│   ├── styles/
│   │   └── global.css               ← Glass & Glow CSS vars + @import tailwindcss
│   ├── content/
│   │   ├── config.ts                ← defineCollection schemas for 'en' and 'zh'
│   │   ├── en/                      ← 8 English .md posts
│   │   └── zh/                      ← 8 Chinese .md posts
│   ├── layouts/
│   │   ├── Base.astro               ← HTML shell + <head> + global CSS
│   │   └── BlogPost.astro           ← article page: Nav + SubNav + Progress + content + TOC
│   ├── components/
│   │   ├── Nav.astro                ← sticky main nav with EN/中文 switcher
│   │   ├── PostCard.astro           ← glass card for timeline
│   │   ├── TimelineFeed.astro       ← timeline with year separators
│   │   ├── TagFilter.astro          ← pill filter row with client-side JS
│   │   ├── ArticleSubNav.astro      ← sticky sub-nav: back link + title + section jumps
│   │   ├── ReadingProgress.astro    ← cyan→purple scroll progress bar
│   │   ├── TableOfContents.astro    ← sticky TOC sidebar with IntersectionObserver
│   │   ├── AuthorCard.astro         ← author bio below article
│   │   └── RelatedPosts.astro       ← 2-col related posts grid
│   └── pages/
│       ├── index.astro              ← redirect to /en/
│       ├── en/
│       │   ├── index.astro          ← EN timeline homepage
│       │   └── [slug].astro         ← EN article page
│       └── zh/
│           ├── index.astro          ← ZH timeline homepage
│           └── [slug].astro         ← ZH article page
```

---

## Task 1: Scaffold Astro project + install deps

**Files:**
- Create: `astro.config.mjs`
- Create: `tsconfig.json`
- Create: `.gitignore`
- Create: `package.json` (via npm create)

- [ ] **Step 1: Initialize Astro project**

```bash
npm create astro@latest . -- --template minimal --typescript strict --no-git --install --yes
```

Expected: `src/`, `public/`, `astro.config.mjs`, `tsconfig.json`, `package.json` created.

- [ ] **Step 2: Install Tailwind CSS 4**

```bash
npm install tailwindcss @tailwindcss/vite
```

- [ ] **Step 3: Replace astro.config.mjs**

```js
// astro.config.mjs
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  site: 'https://blog.icmoc.com',
  vite: {
    plugins: [tailwindcss()],
  },
});
```

- [ ] **Step 4: Replace tsconfig.json**

```json
{
  "extends": "astro/tsconfigs/strict",
  "compilerOptions": {
    "baseUrl": "."
  }
}
```

- [ ] **Step 5: Create .gitignore**

```
node_modules/
dist/
.astro/
.env
.env.*
.superpowers/
```

- [ ] **Step 6: Verify build passes**

```bash
npm run build
```

Expected: `dist/` created, no errors.

- [ ] **Step 7: Commit**

```bash
git add package.json package-lock.json astro.config.mjs tsconfig.json .gitignore
git commit -m "feat: scaffold Astro 5 + Tailwind CSS 4"
```

---

## Task 2: Glass & Glow global styles

**Files:**
- Create: `src/styles/global.css`
- Create: `public/favicon.svg`

- [ ] **Step 1: Create global.css**

```css
/* src/styles/global.css */
@import "tailwindcss";

:root {
  --bg-base: #1a1a2e;
  --bg-mid: #16213e;
  --bg-deep: #0f3460;
  --cyan: #00d4ff;
  --purple: #a855f7;
  --blue: #60a5fa;
  --orange: #fb923c;
  --green: #34d399;
  --text-primary: #e2e8f0;
  --text-muted: rgba(255, 255, 255, 0.45);
  --text-dim: rgba(255, 255, 255, 0.25);
  --glass-bg: rgba(255, 255, 255, 0.05);
  --glass-border: rgba(255, 255, 255, 0.08);
  --glass-hover: rgba(255, 255, 255, 0.08);
  --nav-height: 56px;
  --subnav-height: 44px;
}

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

html { scroll-behavior: smooth; }

body {
  background: linear-gradient(135deg, var(--bg-base) 0%, var(--bg-mid) 50%, var(--bg-deep) 100%);
  background-attachment: fixed;
  min-height: 100vh;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  color: var(--text-primary);
}

body::before {
  content: '';
  position: fixed; top: -100px; right: -100px;
  width: 500px; height: 500px;
  background: radial-gradient(circle, rgba(0, 212, 255, 0.07), transparent 70%);
  pointer-events: none; z-index: 0;
}
body::after {
  content: '';
  position: fixed; bottom: -100px; left: -100px;
  width: 400px; height: 400px;
  background: radial-gradient(circle, rgba(168, 85, 247, 0.07), transparent 70%);
  pointer-events: none; z-index: 0;
}

/* Tag colour helpers — used in PostCard, BlogPost, RelatedPosts */
.tag-ai     { background: rgba(0,212,255,0.12);   color: var(--cyan);   border: 1px solid rgba(0,212,255,0.25); }
.tag-ruby   { background: rgba(168,85,247,0.12);  color: var(--purple); border: 1px solid rgba(168,85,247,0.25); }
.tag-chrome { background: rgba(96,165,250,0.12);  color: var(--blue);   border: 1px solid rgba(96,165,250,0.25); }
.tag-rails  { background: rgba(251,146,60,0.12);  color: var(--orange); border: 1px solid rgba(251,146,60,0.25); }
.tag-product { background: rgba(52,211,153,0.12); color: var(--green);  border: 1px solid rgba(52,211,153,0.25); }

/* Prose — applied to article body via .prose wrapper */
.prose { font-size: 16px; line-height: 1.85; color: rgba(255,255,255,0.72); }
.prose p  { margin-bottom: 22px; }
.prose h2 { font-size: 22px; font-weight: 700; color: #fff; margin: 40px 0 14px; }
.prose h3 { font-size: 17px; font-weight: 700; color: rgba(255,255,255,0.9); margin: 30px 0 10px; }
.prose strong { color: #fff; font-weight: 600; }
.prose a  { color: var(--cyan); text-decoration: none; border-bottom: 1px solid rgba(0,212,255,0.3); }
.prose ul, .prose ol { padding-left: 24px; margin-bottom: 22px; }
.prose li { margin-bottom: 6px; }
.prose code {
  background: rgba(0,212,255,0.08); border: 1px solid rgba(0,212,255,0.15);
  border-radius: 4px; padding: 2px 7px;
  font-size: 13.5px; font-family: 'SF Mono', 'Fira Code', monospace; color: var(--cyan);
}
.prose pre {
  background: rgba(0,0,0,0.45); border: 1px solid rgba(255,255,255,0.08);
  border-radius: 10px; padding: 22px; margin: 24px 0; overflow-x: auto;
}
.prose pre code { background: none; border: none; padding: 0; font-size: 13.5px; color: var(--text-primary); line-height: 1.65; }
.prose blockquote {
  border-left: 3px solid rgba(168,85,247,0.5);
  padding: 14px 22px; margin: 28px 0;
  background: rgba(168,85,247,0.05); border-radius: 0 8px 8px 0;
  color: rgba(255,255,255,0.6); font-style: italic;
}
```

- [ ] **Step 2: Create favicon.svg**

```svg
<!-- public/favicon.svg -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <circle cx="16" cy="16" r="16" fill="#1a1a2e"/>
  <text x="16" y="21" text-anchor="middle" font-family="system-ui" font-size="16" font-weight="800" fill="#00d4ff">E</text>
</svg>
```

- [ ] **Step 3: Verify dev server loads with styles**

```bash
npm run dev
```

Expected: server starts at `http://localhost:4321`, no CSS errors in terminal.

- [ ] **Step 4: Commit**

```bash
git add src/styles/global.css public/favicon.svg
git commit -m "feat: Glass & Glow global CSS theme"
```

---

## Task 3: Content collection schema

**Files:**
- Create: `src/content/config.ts`

- [ ] **Step 1: Create config.ts**

```ts
// src/content/config.ts
import { defineCollection, z } from 'astro:content';

const postSchema = z.object({
  title: z.string(),
  date: z.coerce.date(),
  tags: z.array(z.string()),
  excerpt: z.string(),
  draft: z.boolean().default(false),
});

const en = defineCollection({ type: 'content', schema: postSchema });
const zh = defineCollection({ type: 'content', schema: postSchema });

export const collections = { en, zh };
```

- [ ] **Step 2: Create placeholder posts to validate schema**

```bash
mkdir -p src/content/en src/content/zh
```

Create `src/content/en/test.md`:
```markdown
---
title: "Test"
date: 2026-06-07
tags: [AI]
excerpt: "Test excerpt"
draft: true
---
Test.
```

Create `src/content/zh/test.md` with identical content.

- [ ] **Step 3: Run type check**

```bash
npx astro check
```

Expected: 0 errors.

- [ ] **Step 4: Remove placeholder files**

```bash
rm src/content/en/test.md src/content/zh/test.md
```

- [ ] **Step 5: Commit**

```bash
git add src/content/config.ts src/content/en src/content/zh
git commit -m "feat: content collection schema for bilingual posts"
```

---

## Task 4: Base layout

**Files:**
- Create: `src/layouts/Base.astro`

- [ ] **Step 1: Create Base.astro**

```astro
---
// src/layouts/Base.astro
import '../styles/global.css';

interface Props {
  title: string;
  description?: string;
  lang?: 'en' | 'zh';
}

const {
  title,
  description = 'Writing by Encore Shao — Full-stack Engineer & AI Researcher',
  lang = 'en',
} = Astro.props;
---

<!doctype html>
<html lang={lang}>
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content={description} />
    <title>{title} · encore.dev</title>
    <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
    <link rel="canonical" href={Astro.url.href} />
  </head>
  <body>
    <slot />
  </body>
</html>
```

- [ ] **Step 2: Run type check**

```bash
npx astro check
```

Expected: 0 errors.

- [ ] **Step 3: Commit**

```bash
git add src/layouts/Base.astro
git commit -m "feat: Base layout"
```

---

## Task 5: Nav component

**Files:**
- Create: `src/components/Nav.astro`

- [ ] **Step 1: Create Nav.astro**

```astro
---
// src/components/Nav.astro
interface Props {
  lang: 'en' | 'zh';
  currentPath?: string;
}

const { lang, currentPath = '' } = Astro.props;
const otherLang = lang === 'en' ? 'zh' : 'en';

const pathParts = currentPath.split('/').filter(Boolean);
const slug = pathParts.length > 1 ? pathParts[pathParts.length - 1] : '';
const altHref = slug ? `/${otherLang}/${slug}` : `/${otherLang}/`;
---

<nav>
  <a class="nav-logo" href={`/${lang}/`}>encore.dev</a>
  <div class="nav-center">
    <a href={`/${lang}/`} class={currentPath.endsWith('/') ? 'active' : ''}>
      {lang === 'en' ? 'Blog' : '博客'}
    </a>
    <a href="https://icmoc.com" target="_blank" rel="noopener">
      {lang === 'en' ? 'Projects' : '项目'}
    </a>
    <a href="https://icmoc.com" target="_blank" rel="noopener">
      {lang === 'en' ? 'About' : '关于'}
    </a>
  </div>
  <div class="lang-switcher">
    <a href={lang === 'en' ? currentPath || `/${lang}/` : altHref}
       class={`lang-btn${lang === 'en' ? ' active' : ''}`}>EN</a>
    <a href={lang === 'zh' ? currentPath || `/${lang}/` : altHref}
       class={`lang-btn${lang === 'zh' ? ' active' : ''}`}>中文</a>
  </div>
</nav>

<style>
  nav {
    position: sticky; top: 0; z-index: 100;
    background: rgba(15, 15, 35, 0.85);
    backdrop-filter: blur(16px);
    -webkit-backdrop-filter: blur(16px);
    border-bottom: 1px solid rgba(255, 255, 255, 0.07);
    padding: 0 40px;
    display: flex; align-items: center; justify-content: space-between;
    height: var(--nav-height);
  }
  .nav-logo { font-size: 16px; font-weight: 800; color: var(--cyan); letter-spacing: -0.5px; text-decoration: none; }
  .nav-center { display: flex; gap: 28px; }
  .nav-center a { font-size: 13px; color: rgba(255,255,255,0.45); text-decoration: none; transition: color 0.2s; }
  .nav-center a:hover, .nav-center a.active { color: #fff; }
  .lang-switcher {
    display: flex; gap: 2px;
    background: rgba(255,255,255,0.06);
    border: 1px solid rgba(255,255,255,0.1);
    border-radius: 6px; padding: 3px;
  }
  .lang-btn {
    padding: 4px 12px; border-radius: 4px;
    font-size: 12px; font-weight: 600; text-decoration: none;
    color: rgba(255,255,255,0.4); transition: all 0.2s;
  }
  .lang-btn.active { background: rgba(0,212,255,0.2); color: var(--cyan); }
</style>
```

- [ ] **Step 2: Run type check**

```bash
npx astro check
```

Expected: 0 errors.

- [ ] **Step 3: Commit**

```bash
git add src/components/Nav.astro
git commit -m "feat: Nav component with language switcher"
```

---

## Task 6: Homepage components (PostCard, TimelineFeed, TagFilter)

**Files:**
- Create: `src/components/PostCard.astro`
- Create: `src/components/TimelineFeed.astro`
- Create: `src/components/TagFilter.astro`

- [ ] **Step 1: Create PostCard.astro**

```astro
---
// src/components/PostCard.astro
interface Props {
  title: string;
  date: Date;
  tags: string[];
  excerpt: string;
  slug: string;
  lang: 'en' | 'zh';
  featured?: boolean;
}

const { title, date, tags, excerpt, slug, lang, featured = false } = Astro.props;

const tagClass: Record<string, string> = {
  AI: 'tag-ai', MCP: 'tag-ai', Agents: 'tag-ai',
  Ruby: 'tag-ruby', 'Open Source': 'tag-ruby', API: 'tag-ruby',
  Chrome: 'tag-chrome',
  Rails: 'tag-rails',
  Product: 'tag-product',
};

const formattedDate = new Intl.DateTimeFormat(lang === 'en' ? 'en-US' : 'zh-CN', {
  year: 'numeric', month: 'short',
}).format(date);
---

<a
  href={`/${lang}/${slug}`}
  class:list={['post-card', { featured }]}
  data-tags={tags.join(',')}
>
  <div class="post-meta">
    <span class="post-date">{formattedDate}</span>
    {tags.slice(0, 2).map(tag => (
      <span class:list={['post-tag', tagClass[tag] ?? 'tag-ai']}>{tag}</span>
    ))}
    <span class="read-time">8 min</span>
  </div>
  <div class="post-title">{title}</div>
  <div class="post-excerpt">{excerpt}</div>
</a>

<style>
  .post-card {
    display: block; text-decoration: none;
    background: var(--glass-bg); border: 1px solid var(--glass-border);
    border-radius: 12px; padding: 20px 24px;
    transition: all 0.25s; margin-bottom: 12px;
  }
  .post-card:hover {
    background: var(--glass-hover);
    border-color: rgba(255,255,255,0.15);
    transform: translateX(4px);
  }
  .post-card.featured { background: rgba(0,212,255,0.06); border-color: rgba(0,212,255,0.2); }
  .post-meta { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; flex-wrap: wrap; }
  .post-date { font-size: 11px; color: rgba(255,255,255,0.35); }
  .post-tag { font-size: 10px; font-weight: 700; padding: 2px 8px; border-radius: 4px; letter-spacing: 0.5px; text-transform: uppercase; }
  .read-time { font-size: 11px; color: rgba(255,255,255,0.25); margin-left: auto; }
  .post-title { font-size: 16px; font-weight: 700; color: #fff; margin-bottom: 6px; line-height: 1.4; }
  .featured .post-title { font-size: 18px; }
  .post-excerpt { font-size: 13px; color: rgba(255,255,255,0.45); line-height: 1.65; }
</style>
```

- [ ] **Step 2: Create TimelineFeed.astro**

```astro
---
// src/components/TimelineFeed.astro
import PostCard from './PostCard.astro';
import type { CollectionEntry } from 'astro:content';

interface Props {
  posts: (CollectionEntry<'en'> | CollectionEntry<'zh'>)[];
  lang: 'en' | 'zh';
}

const { posts, lang } = Astro.props;

const sorted = [...posts]
  .filter(p => !p.data.draft)
  .sort((a, b) => b.data.date.valueOf() - a.data.date.valueOf());

const byYear = sorted.reduce<Record<number, typeof sorted>>((acc, post) => {
  const year = post.data.date.getFullYear();
  (acc[year] ??= []).push(post);
  return acc;
}, {});

const years = Object.keys(byYear).map(Number).sort((a, b) => b - a);
const dotColors = ['dot-cyan', 'dot-purple', 'dot-blue', 'dot-dim'] as const;
---

<div class="timeline" id="timeline-feed">
  {years.map(year => (
    <div class="year-group">
      <div class="year-label">{year}</div>
      {byYear[year].map((post, i) => (
        <div class="timeline-item">
          <div class:list={['timeline-dot', dotColors[i % dotColors.length]]}></div>
          <PostCard
            title={post.data.title}
            date={post.data.date}
            tags={post.data.tags}
            excerpt={post.data.excerpt}
            slug={post.slug}
            lang={lang}
            featured={i === 0 && year === years[0]}
          />
        </div>
      ))}
    </div>
  ))}
</div>

<style>
  .timeline { position: relative; padding-left: 28px; }
  .timeline::before {
    content: ''; position: absolute; left: 0; top: 8px; bottom: 0; width: 2px;
    background: linear-gradient(180deg, rgba(0,212,255,0.6), rgba(168,85,247,0.3), rgba(255,255,255,0.05));
  }
  .year-label {
    font-size: 11px; font-weight: 700; color: rgba(255,255,255,0.2);
    letter-spacing: 2px; text-transform: uppercase;
    margin-bottom: 16px; margin-top: 8px;
    display: flex; align-items: center; gap: 10px;
  }
  .year-label::after { content: ''; flex: 1; height: 1px; background: rgba(255,255,255,0.06); }
  .timeline-item { position: relative; }
  .timeline-dot {
    position: absolute; left: -34px; top: 20px;
    width: 10px; height: 10px; border-radius: 50%; border: 2px solid;
  }
  .dot-cyan   { background: rgba(0,212,255,0.3);   border-color: var(--cyan);   box-shadow: 0 0 10px rgba(0,212,255,0.5); }
  .dot-purple { background: rgba(168,85,247,0.3);  border-color: var(--purple); box-shadow: 0 0 8px rgba(168,85,247,0.4); }
  .dot-blue   { background: rgba(96,165,250,0.3);  border-color: var(--blue);   box-shadow: 0 0 8px rgba(96,165,250,0.3); }
  .dot-dim    { background: rgba(255,255,255,0.05); border-color: rgba(255,255,255,0.15); }
</style>
```

- [ ] **Step 3: Create TagFilter.astro**

```astro
---
// src/components/TagFilter.astro
interface Props {
  tags: string[];
  lang: 'en' | 'zh';
}

const { tags, lang } = Astro.props;
const allLabel = lang === 'en' ? 'All' : '全部';
---

<div class="tag-filters" id="tag-filters">
  <button class="tag active" data-tag="all">{allLabel}</button>
  {tags.map(tag => (
    <button class="tag" data-tag={tag}>{tag}</button>
  ))}
</div>

<script>
  const filters = document.getElementById('tag-filters')!;
  const feed    = document.getElementById('timeline-feed')!;

  filters.addEventListener('click', (e) => {
    const btn = (e.target as HTMLElement).closest<HTMLButtonElement>('.tag');
    if (!btn) return;

    filters.querySelectorAll('.tag').forEach(t => t.classList.remove('active'));
    btn.classList.add('active');

    const selected = btn.dataset.tag ?? 'all';

    feed.querySelectorAll<HTMLElement>('.timeline-item').forEach(item => {
      const card = item.querySelector<HTMLElement>('.post-card');
      const cardTags = card?.dataset.tags?.split(',') ?? [];
      item.style.display = (selected === 'all' || cardTags.includes(selected)) ? '' : 'none';
    });

    feed.querySelectorAll<HTMLElement>('.year-group').forEach(group => {
      const hasVisible = [...group.querySelectorAll<HTMLElement>('.timeline-item')]
        .some(item => item.style.display !== 'none');
      group.style.display = hasVisible ? '' : 'none';
    });
  });
</script>

<style>
  .tag-filters { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 40px; }
  .tag {
    padding: 6px 14px; border-radius: 20px;
    font-size: 12px; font-weight: 600; cursor: pointer;
    border: 1px solid rgba(255,255,255,0.1);
    background: rgba(255,255,255,0.04); color: rgba(255,255,255,0.5);
    transition: all 0.2s;
  }
  .tag.active { background: rgba(0,212,255,0.15); border-color: rgba(0,212,255,0.4); color: var(--cyan); }
  .tag:hover  { border-color: rgba(255,255,255,0.25); color: rgba(255,255,255,0.8); }
</style>
```

- [ ] **Step 4: Run type check**

```bash
npx astro check
```

Expected: 0 errors.

- [ ] **Step 5: Commit**

```bash
git add src/components/PostCard.astro src/components/TimelineFeed.astro src/components/TagFilter.astro
git commit -m "feat: PostCard, TimelineFeed, TagFilter components"
```

---

## Task 7: Homepage pages

**Files:**
- Create: `src/pages/index.astro`
- Create: `src/pages/en/index.astro`
- Create: `src/pages/zh/index.astro`

- [ ] **Step 1: Create root redirect**

```astro
---
// src/pages/index.astro
return Astro.redirect('/en/');
---
```

- [ ] **Step 2: Create EN homepage**

```astro
---
// src/pages/en/index.astro
import Base from '../../layouts/Base.astro';
import Nav from '../../components/Nav.astro';
import TimelineFeed from '../../components/TimelineFeed.astro';
import TagFilter from '../../components/TagFilter.astro';
import { getCollection } from 'astro:content';

const posts = await getCollection('en', ({ data }) => !data.draft);
const allTags = [...new Set(posts.flatMap(p => p.data.tags))].sort();
---

<Base title="Writing" lang="en">
  <Nav lang="en" currentPath="/en/" />
  <main>
    <div class="page-header">
      <h1>Writing</h1>
      <p>Thoughts on engineering, AI, and shipping software</p>
    </div>
    <TagFilter tags={allTags} lang="en" />
    <TimelineFeed posts={posts} lang="en" />
  </main>
  <footer>
    Built with Astro ·
    <a href="https://github.com/encoreshao" target="_blank" rel="noopener">GitHub</a> ·
    <a href="https://icmoc.com" target="_blank" rel="noopener">icmoc.com</a>
  </footer>
</Base>

<style>
  main   { max-width: 720px; margin: 0 auto; padding: 48px 24px; position: relative; z-index: 1; }
  .page-header { margin-bottom: 40px; }
  .page-header h1 { font-size: 28px; font-weight: 800; color: #fff; margin-bottom: 6px; }
  .page-header p  { font-size: 14px; color: rgba(255,255,255,0.4); }
  footer {
    text-align: center; padding: 40px 24px;
    font-size: 12px; color: rgba(255,255,255,0.2);
    border-top: 1px solid rgba(255,255,255,0.06);
    position: relative; z-index: 1;
  }
  footer a { color: var(--cyan); text-decoration: none; }
</style>
```

- [ ] **Step 3: Create ZH homepage**

```astro
---
// src/pages/zh/index.astro
import Base from '../../layouts/Base.astro';
import Nav from '../../components/Nav.astro';
import TimelineFeed from '../../components/TimelineFeed.astro';
import TagFilter from '../../components/TagFilter.astro';
import { getCollection } from 'astro:content';

const posts = await getCollection('zh', ({ data }) => !data.draft);
const allTags = [...new Set(posts.flatMap(p => p.data.tags))].sort();
---

<Base title="文章" lang="zh">
  <Nav lang="zh" currentPath="/zh/" />
  <main>
    <div class="page-header">
      <h1>文章</h1>
      <p>关于工程、AI 和软件交付的思考</p>
    </div>
    <TagFilter tags={allTags} lang="zh" />
    <TimelineFeed posts={posts} lang="zh" />
  </main>
  <footer>
    基于 Astro 构建 ·
    <a href="https://github.com/encoreshao" target="_blank" rel="noopener">GitHub</a> ·
    <a href="https://icmoc.com" target="_blank" rel="noopener">icmoc.com</a>
  </footer>
</Base>

<style>
  main   { max-width: 720px; margin: 0 auto; padding: 48px 24px; position: relative; z-index: 1; }
  .page-header { margin-bottom: 40px; }
  .page-header h1 { font-size: 28px; font-weight: 800; color: #fff; margin-bottom: 6px; }
  .page-header p  { font-size: 14px; color: rgba(255,255,255,0.4); }
  footer {
    text-align: center; padding: 40px 24px;
    font-size: 12px; color: rgba(255,255,255,0.2);
    border-top: 1px solid rgba(255,255,255,0.06);
    position: relative; z-index: 1;
  }
  footer a { color: var(--cyan); text-decoration: none; }
</style>
```

- [ ] **Step 4: Run type check**

```bash
npx astro check
```

Expected: 0 errors.

- [ ] **Step 5: Commit**

```bash
git add src/pages/index.astro src/pages/en/index.astro src/pages/zh/index.astro
git commit -m "feat: homepage pages for EN and ZH with timeline + tag filter"
```

---

## Task 8: Article page components

**Files:**
- Create: `src/components/ArticleSubNav.astro`
- Create: `src/components/ReadingProgress.astro`
- Create: `src/components/TableOfContents.astro`
- Create: `src/components/AuthorCard.astro`
- Create: `src/components/RelatedPosts.astro`

- [ ] **Step 1: Create ArticleSubNav.astro**

```astro
---
// src/components/ArticleSubNav.astro
interface Props {
  title: string;
  lang: 'en' | 'zh';
  headings: { depth: number; slug: string; text: string }[];
}

const { title, lang, headings } = Astro.props;
const h2s = headings.filter(h => h.depth === 2).slice(0, 4);
const backLabel = lang === 'en' ? '← All posts' : '← 所有文章';
---

<div class="article-subnav">
  <a class="subnav-back" href={`/${lang}/`}>{backLabel}</a>
  <div class="subnav-sep"></div>
  <div class="subnav-title">{title}</div>
  {h2s.length > 0 && (
    <nav class="subnav-toc">
      {h2s.map(h => <a href={`#${h.slug}`}>{h.text}</a>)}
    </nav>
  )}
</div>

<style>
  .article-subnav {
    position: sticky; top: var(--nav-height); z-index: 99;
    background: rgba(10, 10, 28, 0.9);
    backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px);
    border-bottom: 1px solid rgba(255,255,255,0.05);
    padding: 0 40px;
    display: flex; align-items: center; gap: 20px;
    height: var(--subnav-height);
  }
  .subnav-back {
    font-size: 12px; color: rgba(255,255,255,0.4); text-decoration: none;
    display: flex; align-items: center; gap: 5px;
    transition: color 0.2s; white-space: nowrap; flex-shrink: 0;
  }
  .subnav-back:hover { color: var(--cyan); }
  .subnav-sep { width: 1px; height: 16px; background: rgba(255,255,255,0.1); flex-shrink: 0; }
  .subnav-title {
    font-size: 12px; color: rgba(255,255,255,0.55); font-weight: 600;
    white-space: nowrap; overflow: hidden; text-overflow: ellipsis; flex: 1;
  }
  .subnav-toc { display: flex; gap: 18px; flex-shrink: 0; }
  .subnav-toc a { font-size: 11px; color: rgba(255,255,255,0.3); text-decoration: none; white-space: nowrap; transition: color 0.2s; }
  .subnav-toc a:hover { color: var(--cyan); }
</style>
```

- [ ] **Step 2: Create ReadingProgress.astro**

```astro
---
// src/components/ReadingProgress.astro
---

<div class="progress-bar">
  <div class="progress-fill" id="progress-fill"></div>
</div>

<script>
  const fill = document.getElementById('progress-fill')!;
  window.addEventListener('scroll', () => {
    const doc = document.documentElement;
    const pct = (doc.scrollTop / (doc.scrollHeight - doc.clientHeight)) * 100;
    fill.style.width = Math.min(pct, 100) + '%';
  }, { passive: true });
</script>

<style>
  .progress-bar {
    position: sticky;
    top: calc(var(--nav-height) + var(--subnav-height));
    z-index: 98; height: 2px; background: rgba(255,255,255,0.05);
  }
  .progress-fill {
    height: 100%; width: 0%;
    background: linear-gradient(90deg, var(--cyan), var(--purple));
    transition: width 0.05s linear;
  }
</style>
```

- [ ] **Step 3: Create TableOfContents.astro**

```astro
---
// src/components/TableOfContents.astro
interface Props {
  headings: { depth: number; slug: string; text: string }[];
  lang: 'en' | 'zh';
}

const { headings, lang } = Astro.props;
const items = headings.filter(h => h.depth === 2 || h.depth === 3);
const label = lang === 'en' ? 'On this page' : '本页目录';
---

<aside class="toc">
  <div class="toc-label">{label}</div>
  {items.map(h => (
    <a
      href={`#${h.slug}`}
      class:list={['toc-item', { sub: h.depth === 3 }]}
      data-slug={h.slug}
    >{h.text}</a>
  ))}
</aside>

<script>
  const links = document.querySelectorAll<HTMLAnchorElement>('.toc-item');
  const observer = new IntersectionObserver(
    entries => {
      entries.forEach(e => {
        if (e.isIntersecting) {
          links.forEach(l => l.classList.toggle('active', l.dataset.slug === e.target.id));
        }
      });
    },
    { rootMargin: '-20% 0px -70% 0px' }
  );
  links.forEach(l => {
    const el = document.getElementById(l.dataset.slug ?? '');
    if (el) observer.observe(el);
  });
</script>

<style>
  .toc {
    position: sticky;
    top: calc(var(--nav-height) + var(--subnav-height) + 2px + 24px);
    background: rgba(255,255,255,0.03); border: 1px solid rgba(255,255,255,0.07);
    border-radius: 12px; padding: 20px;
  }
  .toc-label { font-size: 10px; font-weight: 700; letter-spacing: 2px; color: rgba(255,255,255,0.25); text-transform: uppercase; margin-bottom: 14px; }
  .toc-item {
    display: block; font-size: 12px; color: rgba(255,255,255,0.35); text-decoration: none;
    padding: 5px 0 5px 10px; border-left: 2px solid rgba(255,255,255,0.06);
    margin-bottom: 2px; transition: all 0.2s; line-height: 1.4;
  }
  .toc-item:hover { color: rgba(255,255,255,0.7); border-left-color: rgba(255,255,255,0.2); }
  .toc-item.active { color: var(--cyan); border-left-color: var(--cyan); }
  .toc-item.sub { padding-left: 20px; font-size: 11px; }
</style>
```

- [ ] **Step 4: Create AuthorCard.astro**

```astro
---
// src/components/AuthorCard.astro
interface Props { lang: 'en' | 'zh'; }
const { lang } = Astro.props;
---

<div class="author-card">
  <div class="author-avatar" aria-hidden="true"></div>
  <div>
    <div class="author-name">Encore Shao</div>
    <p class="author-bio">
      {lang === 'en'
        ? 'Full-stack Engineer & AI Researcher at Ekohe, Shanghai. Building scalable Rails apps and agentic AI systems for 10+ years.'
        : '全栈工程师 & AI 研究员，就职于上海 Ekohe。10 年以上经验，专注于 Rails 应用与 Agentic AI 系统。'}
    </p>
  </div>
</div>

<style>
  .author-card {
    margin-top: 56px; background: rgba(255,255,255,0.04);
    border: 1px solid rgba(255,255,255,0.08); border-radius: 14px;
    padding: 24px; display: flex; gap: 18px; align-items: center;
  }
  .author-avatar { width: 52px; height: 52px; border-radius: 50%; flex-shrink: 0; background: linear-gradient(135deg, var(--cyan), var(--purple)); }
  .author-name { font-size: 15px; font-weight: 700; color: #fff; margin-bottom: 4px; }
  .author-bio  { font-size: 13px; color: rgba(255,255,255,0.45); line-height: 1.5; }
</style>
```

- [ ] **Step 5: Create RelatedPosts.astro**

```astro
---
// src/components/RelatedPosts.astro
import type { CollectionEntry } from 'astro:content';

interface Props {
  posts: (CollectionEntry<'en'> | CollectionEntry<'zh'>)[];
  lang: 'en' | 'zh';
  currentSlug: string;
  currentTags: string[];
}

const { posts, lang, currentSlug, currentTags } = Astro.props;
const label = lang === 'en' ? 'More from Encore' : '更多文章';

const tagClass: Record<string, string> = {
  AI: 'tag-ai', MCP: 'tag-ai', Agents: 'tag-ai',
  Ruby: 'tag-ruby', 'Open Source': 'tag-ruby', API: 'tag-ruby',
  Chrome: 'tag-chrome', Rails: 'tag-rails', Product: 'tag-product',
};

const related = posts
  .filter(p => p.slug !== currentSlug && !p.data.draft)
  .sort((a, b) =>
    b.data.tags.filter(t => currentTags.includes(t)).length -
    a.data.tags.filter(t => currentTags.includes(t)).length
  )
  .slice(0, 2);
---

{related.length > 0 && (
  <div class="related">
    <div class="related-label">{label}</div>
    <div class="related-grid">
      {related.map(post => (
        <a class="related-card" href={`/${lang}/${post.slug}`}>
          <span class:list={['related-tag', tagClass[post.data.tags[0]] ?? 'tag-ai']}>
            {post.data.tags.slice(0, 2).join(' · ')}
          </span>
          <div class="related-title">{post.data.title}</div>
        </a>
      ))}
    </div>
  </div>
)}

<style>
  .related { margin-top: 48px; }
  .related-label { font-size: 11px; font-weight: 700; color: rgba(255,255,255,0.25); letter-spacing: 2px; text-transform: uppercase; margin-bottom: 16px; }
  .related-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
  .related-card {
    background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.07);
    border-radius: 10px; padding: 16px; text-decoration: none; display: block; transition: all 0.2s;
  }
  .related-card:hover { background: rgba(255,255,255,0.07); transform: translateY(-2px); }
  .related-tag { font-size: 10px; font-weight: 700; padding: 2px 8px; border-radius: 4px; letter-spacing: 0.5px; text-transform: uppercase; display: inline-block; margin-bottom: 6px; }
  .related-title { font-size: 13px; font-weight: 700; color: rgba(255,255,255,0.85); line-height: 1.4; }
</style>
```

- [ ] **Step 6: Run type check**

```bash
npx astro check
```

Expected: 0 errors.

- [ ] **Step 7: Commit**

```bash
git add src/components/ArticleSubNav.astro src/components/ReadingProgress.astro src/components/TableOfContents.astro src/components/AuthorCard.astro src/components/RelatedPosts.astro
git commit -m "feat: article page components (sub-nav, progress bar, TOC, author card, related posts)"
```

---

## Task 9: BlogPost layout + article pages

**Files:**
- Create: `src/layouts/BlogPost.astro`
- Create: `src/pages/en/[slug].astro`
- Create: `src/pages/zh/[slug].astro`

- [ ] **Step 1: Create BlogPost.astro**

```astro
---
// src/layouts/BlogPost.astro
import Base from './Base.astro';
import Nav from '../components/Nav.astro';
import ArticleSubNav from '../components/ArticleSubNav.astro';
import ReadingProgress from '../components/ReadingProgress.astro';
import TableOfContents from '../components/TableOfContents.astro';
import AuthorCard from '../components/AuthorCard.astro';
import RelatedPosts from '../components/RelatedPosts.astro';
import type { CollectionEntry } from 'astro:content';

interface Props {
  post: CollectionEntry<'en'> | CollectionEntry<'zh'>;
  lang: 'en' | 'zh';
  headings: { depth: number; slug: string; text: string }[];
  relatedPosts: (CollectionEntry<'en'> | CollectionEntry<'zh'>)[];
}

const { post, lang, headings, relatedPosts } = Astro.props;
const { title, date, tags, excerpt } = post.data;

const tagClass: Record<string, string> = {
  AI: 'tag-ai', MCP: 'tag-ai', Agents: 'tag-ai',
  Ruby: 'tag-ruby', 'Open Source': 'tag-ruby', API: 'tag-ruby',
  Chrome: 'tag-chrome', Rails: 'tag-rails', Product: 'tag-product',
};

const formattedDate = new Intl.DateTimeFormat(lang === 'en' ? 'en-US' : 'zh-CN', {
  year: 'numeric', month: 'long', day: 'numeric',
}).format(date);
---

<Base title={title} lang={lang}>
  <Nav lang={lang} currentPath={`/${lang}/${post.slug}`} />
  <ArticleSubNav title={title} lang={lang} headings={headings} />
  <ReadingProgress />

  <div class="page-wrap">
    <article>
      <header>
        <div class="article-meta">
          {tags.slice(0, 2).map(tag => (
            <span class:list={['post-tag', tagClass[tag] ?? 'tag-ai']}>{tag}</span>
          ))}
          <span class="meta-sep">·</span>
          <span class="meta-text">{formattedDate}</span>
          <span class="meta-sep">·</span>
          <span class="meta-text">8 {lang === 'en' ? 'min read' : '分钟阅读'}</span>
        </div>
        <h1 class="article-title">{title}</h1>
        <p class="article-excerpt">{excerpt}</p>
      </header>

      <hr class="divider" />

      <div class="prose">
        <slot />
      </div>

      <AuthorCard lang={lang} />
      <RelatedPosts
        posts={relatedPosts}
        lang={lang}
        currentSlug={post.slug}
        currentTags={tags}
      />
    </article>

    <TableOfContents headings={headings} lang={lang} />
  </div>

  <footer>
    {lang === 'en' ? 'Built with Astro' : '基于 Astro 构建'} ·
    <a href={`/${lang}/`}>{lang === 'en' ? 'Back to blog' : '返回博客'}</a> ·
    <a href="https://github.com/encoreshao" target="_blank" rel="noopener">GitHub</a>
  </footer>
</Base>

<style>
  .page-wrap {
    max-width: 1100px; margin: 0 auto; padding: 48px 32px 80px;
    display: grid; grid-template-columns: 1fr 220px; gap: 56px;
    align-items: start; position: relative; z-index: 1;
  }
  .article-meta { display: flex; align-items: center; gap: 8px; margin-bottom: 16px; flex-wrap: wrap; }
  .post-tag { font-size: 10px; font-weight: 700; padding: 3px 10px; border-radius: 4px; letter-spacing: 0.5px; text-transform: uppercase; }
  .meta-sep  { color: rgba(255,255,255,0.15); }
  .meta-text { font-size: 12px; color: rgba(255,255,255,0.35); }
  .article-title { font-size: 36px; font-weight: 800; color: #fff; line-height: 1.2; margin-bottom: 18px; letter-spacing: -0.5px; }
  .article-excerpt {
    font-size: 17px; color: rgba(255,255,255,0.5); line-height: 1.7;
    border-left: 3px solid rgba(0,212,255,0.4); padding-left: 18px; font-style: italic;
  }
  .divider { height: 1px; border: none; background: rgba(255,255,255,0.07); margin: 36px 0; }
  footer {
    text-align: center; padding: 40px; font-size: 12px;
    color: rgba(255,255,255,0.2); border-top: 1px solid rgba(255,255,255,0.06);
    position: relative; z-index: 1;
  }
  footer a { color: var(--cyan); text-decoration: none; }
  @media (max-width: 900px) {
    .page-wrap { grid-template-columns: 1fr; }
    .page-wrap aside { display: none; }
  }
</style>
```

- [ ] **Step 2: Create EN article page**

```astro
---
// src/pages/en/[slug].astro
import BlogPost from '../../layouts/BlogPost.astro';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const posts = await getCollection('en', ({ data }) => !data.draft);
  return posts.map(post => ({ params: { slug: post.slug }, props: { post } }));
}

const { post } = Astro.props;
const { Content, headings } = await post.render();
const allPosts = await getCollection('en', ({ data }) => !data.draft);
---

<BlogPost post={post} lang="en" headings={headings} relatedPosts={allPosts}>
  <Content />
</BlogPost>
```

- [ ] **Step 3: Create ZH article page**

```astro
---
// src/pages/zh/[slug].astro
import BlogPost from '../../layouts/BlogPost.astro';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const posts = await getCollection('zh', ({ data }) => !data.draft);
  return posts.map(post => ({ params: { slug: post.slug }, props: { post } }));
}

const { post } = Astro.props;
const { Content, headings } = await post.render();
const allPosts = await getCollection('zh', ({ data }) => !data.draft);
---

<BlogPost post={post} lang="zh" headings={headings} relatedPosts={allPosts}>
  <Content />
</BlogPost>
```

- [ ] **Step 4: Run type check**

```bash
npx astro check
```

Expected: 0 errors.

- [ ] **Step 5: Commit**

```bash
git add src/layouts/BlogPost.astro src/pages/en/[slug].astro src/pages/zh/[slug].astro
git commit -m "feat: BlogPost layout and EN/ZH article pages"
```

---

## Task 10: English articles

Write 8 experience-first posts. Voice: first-person, conversational, real lessons — not tutorial docs. 800–1200 words each. Fetch repo details before writing each post.

**Files:** `src/content/en/01-bamboohr-mcp.md` through `src/content/en/08-workflowpro.md`

- [ ] **Step 1: Fetch bamboohr-mcp repo and write post**

```bash
gh repo view encoreshao/bamboohr-mcp --json description,readme,topics
```

Create `src/content/en/01-bamboohr-mcp.md`:

```markdown
---
title: "Building bamboohr-mcp: An MCP Server for HR APIs"
date: 2026-06-01
tags: [AI, MCP]
excerpt: "I wanted to let any LLM talk to BambooHR's API. Three days later I had a production MCP server in TypeScript. Here's exactly what I built and what surprised me along the way."
draft: false
---

[900–1100 word article. Structure:
1. The frustration: HR team pulling reports manually every week
2. What MCP is and why it fit — universal adapter, any LLM client
3. The build: TypeScript, 12 tools from 80+ endpoints, why those 12
4. The code: show the tool definition shape, the auth pattern
5. The surprise: non-technical HR manager using it directly in Claude
6. What I'd change: versioning strategy, rate limiting, error messages]
```

Write the full article body in place of the structure notes above.

- [ ] **Step 2: Fetch china_regions repo and write post**

```bash
gh repo view encoreshao/china_regions --json description,readme,topics
```

Create `src/content/en/02-china-regions.md`:

```markdown
---
title: "china_regions: Lessons from a 25-Star Ruby Gem"
date: 2026-05-10
tags: [Ruby, "Open Source"]
excerpt: "What I learned shipping a Ruby library for Chinese administrative regions — and why documentation matters more than the code itself."
draft: false
---
```

Write 800–1000 word article: the problem (inconsistent region data in Rails apps), gem design decisions, what drove the 25 stars, documentation as the real product, what you'd change.

- [ ] **Step 3: Fetch bookmark-dashboard repo and write post**

```bash
gh repo view encoreshao/bookmark-dashboard --json description,readme,topics
```

Create `src/content/en/03-bookmark-dashboard.md`:

```markdown
---
title: "AI-Powered Bookmark Dashboard: A Chrome Extension Story"
date: 2026-04-15
tags: [AI, Chrome]
excerpt: "Replacing the new tab page with something actually useful — how I built a bookmark dashboard powered by agentic AI, and what I'd do differently."
draft: false
---
```

Write 900–1100 word article: the problem with new tab pages, Chrome extension architecture, what "AI-powered" concretely means here, hardest Chrome API moments, what users actually use.

- [ ] **Step 4: Write RanBot / agentic AI post**

Create `src/content/en/04-agentic-ai-ranbot.md`:

```markdown
---
title: "Agentic AI in Production: What I Learned Building RanBot"
date: 2026-03-20
tags: [AI, Agents]
excerpt: "Autonomous workflows sound great until they hit the real world. Twelve months of running agentic systems in production, and the lessons I keep coming back to."
draft: false
---
```

Write 1000–1200 word article: what RanBot is, first production incident, three patterns that actually work, where agents still break down, where the field is heading.

- [ ] **Step 5: Write Rails 10-year retrospective post**

Create `src/content/en/05-ten-years-rails.md`:

```markdown
---
title: "10 Years of Rails: What I Still Reach For Every Day"
date: 2025-12-10
tags: [Ruby, Rails]
excerpt: "Not a framework review. A personal account of which Rails patterns aged well, which didn't, and what I've built that I'm still proud of."
draft: false
---
```

Write 900–1100 word article: first Rails project mistakes, patterns that aged well (migrations, conventions, Active Record), what you stopped doing (service object over-abstraction), proudest projects, when you still choose Rails.

- [ ] **Step 6: Write TrendShop post**

Create `src/content/en/06-trendshop.md`:

```markdown
---
title: "Building TrendShop: When AI Meets Fashion Discovery"
date: 2025-10-05
tags: [AI, Product]
excerpt: "How we built a social fashion platform powered by AI recommendation — what worked, what the users actually wanted, and the pivot we almost didn't make."
draft: false
---
```

Write 900–1100 word article: the original idea, recommendation engine tech, gap between assumption and user behaviour, the pivot, lessons for AI product builders.

- [ ] **Step 7: Fetch crunchbase-ruby-library repo and write post**

```bash
gh repo view encoreshao/crunchbase-ruby-library --json description,readme,topics
```

Create `src/content/en/07-crunchbase-ruby.md`:

```markdown
---
title: "Crunchbase API in Ruby: A Library Worth Building"
date: 2025-08-20
tags: [Ruby, API]
excerpt: "Why I built a Ruby wrapper for the Crunchbase API instead of just writing API calls, and what the experience taught me about library design."
draft: false
---
```

Write 800–1000 word article: use case, gem vs raw calls, design decisions (auth, pagination, error handling), what went wrong in v1, principles of a good API wrapper.

- [ ] **Step 8: Write WorkflowPro post**

Create `src/content/en/08-workflowpro.md`:

```markdown
---
title: "WorkflowPro: Automating Office Work with Rails"
date: 2025-06-15
tags: [Rails, Product]
excerpt: "Building an office automation system with HR and workflow integration — what I learned about enterprise software and why simplicity wins."
draft: false
---
```

Write 900–1100 word article: client problem, Rails architecture for 100+ users, integration challenges, enterprise realities, what made it succeed.

- [ ] **Step 9: Build and verify all EN posts render**

```bash
npm run build
```

Expected: `dist/en/` contains `index.html` + 8 post directories each with `index.html`. 0 errors.

- [ ] **Step 10: Commit**

```bash
git add src/content/en/
git commit -m "feat: 8 English articles"
```

---

## Task 11: Chinese articles

Write Chinese counterparts. Adapt naturally for a Chinese developer audience — not a word-for-word translation. Each mirrors its EN slug.

**Files:** `src/content/zh/01-bamboohr-mcp.md` through `src/content/zh/08-workflowpro.md`

- [ ] **Step 1: Write `src/content/zh/01-bamboohr-mcp.md`**

```markdown
---
title: "构建 bamboohr-mcp：为 HR API 打造 MCP 服务器"
date: 2026-06-01
tags: [AI, MCP]
excerpt: "我想让任何 LLM 都能直接调用 BambooHR 的 API。三天后，我用 TypeScript 搭建了一个生产级 MCP 服务器。这是我的构建过程，以及途中让我意外的事。"
draft: false
---
```

Write 900–1100 word Chinese article following the same structure as the EN version, rewritten naturally.

- [ ] **Step 2: Write `src/content/zh/02-china-regions.md`**

```markdown
---
title: "china_regions：一个 25 Star Ruby Gem 背后的故事"
date: 2026-05-10
tags: [Ruby, "Open Source"]
excerpt: "我从这个中国行政区划 Ruby 库中学到的东西——以及为什么文档比代码本身更重要。"
draft: false
---
```

- [ ] **Step 3: Write `src/content/zh/03-bookmark-dashboard.md`**

```markdown
---
title: "AI 驱动的书签仪表板：一个 Chrome 扩展的故事"
date: 2026-04-15
tags: [AI, Chrome]
excerpt: "把新标签页变成真正有用的工具——我是如何构建这个 AI 驱动的书签仪表板的，以及我会如何重新做。"
draft: false
---
```

- [ ] **Step 4: Write `src/content/zh/04-agentic-ai-ranbot.md`**

```markdown
---
title: "生产环境中的 Agentic AI：构建 RanBot 的那些教训"
date: 2026-03-20
tags: [AI, Agents]
excerpt: "自主工作流在纸面上很美好，直到遇上真实世界。十二个月生产环境的运行经验，以及我一再想起的那些教训。"
draft: false
---
```

- [ ] **Step 5: Write `src/content/zh/05-ten-years-rails.md`**

```markdown
---
title: "Rails 十年：那些我每天还在用的东西"
date: 2025-12-10
tags: [Ruby, Rails]
excerpt: "这不是一篇框架评测。这是我个人的记录：哪些 Rails 模式经住了时间考验，哪些没有，以及我至今仍为之自豪的项目。"
draft: false
---
```

- [ ] **Step 6: Write `src/content/zh/06-trendshop.md`**

```markdown
---
title: "构建 TrendShop：当 AI 遇上时尚发现"
date: 2025-10-05
tags: [AI, Product]
excerpt: "我们如何打造一个 AI 驱动的社交时尚平台——什么有效，用户真正想要什么，以及那次我们差点没做的转型。"
draft: false
---
```

- [ ] **Step 7: Write `src/content/zh/07-crunchbase-ruby.md`**

```markdown
---
title: "用 Ruby 封装 Crunchbase API：一个值得做的库"
date: 2025-08-20
tags: [Ruby, API]
excerpt: "为什么我选择封装一个 Ruby gem 而不是直接写 API 调用，以及这段经历教会我的库设计心得。"
draft: false
---
```

- [ ] **Step 8: Write `src/content/zh/08-workflowpro.md`**

```markdown
---
title: "WorkflowPro：用 Rails 自动化办公流程"
date: 2025-06-15
tags: [Rails, Product]
excerpt: "构建一套含 HR 和审批流程集成的办公自动化系统——我对企业软件的体会，以及为什么简单才是王道。"
draft: false
---
```

- [ ] **Step 9: Build and verify all ZH posts render**

```bash
npm run build
```

Expected: `dist/zh/` contains `index.html` + 8 post directories. 0 errors.

- [ ] **Step 10: Commit**

```bash
git add src/content/zh/
git commit -m "feat: 8 Chinese articles"
```

---

## Task 12: Deploy script and nginx config

**Files:**
- Create: `deploy.sh`
- Create: `nginx.conf.example`

- [ ] **Step 1: Create deploy.sh**

```bash
#!/usr/bin/env bash
# Usage: DEPLOY_HOST=myserver.com DEPLOY_USER=root ./deploy.sh
set -euo pipefail

REMOTE_USER="${DEPLOY_USER:-root}"
REMOTE_HOST="${DEPLOY_HOST:?Set DEPLOY_HOST=yourserver.com}"
REMOTE_PATH="${DEPLOY_PATH:-/var/www/blog}"

echo "Building..."
npm run build

echo "Deploying to ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH} ..."
rsync -avz --delete dist/ "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/"

echo "Done — https://blog.icmoc.com"
```

```bash
chmod +x deploy.sh
```

- [ ] **Step 2: Create nginx.conf.example**

```nginx
# Place in /etc/nginx/sites-available/blog.icmoc.com
# Enable: ln -s /etc/nginx/sites-available/blog.icmoc.com /etc/nginx/sites-enabled/
# Reload:  nginx -t && systemctl reload nginx

server {
    listen 80;
    listen [::]:80;
    server_name blog.icmoc.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name blog.icmoc.com;

    root /var/www/blog;
    index index.html;

    # ssl_certificate     /etc/letsencrypt/live/blog.icmoc.com/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/blog.icmoc.com/privkey.pem;

    location / {
        try_files $uri $uri/ $uri.html =404;
    }

    location ~* \.(js|css|png|svg|ico|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    gzip on;
    gzip_types text/html text/css application/javascript application/json;
}
```

- [ ] **Step 3: Final full build + type check**

```bash
npx astro check && npm run build
```

Expected: 0 errors. `dist/` contains `en/`, `zh/`, all 16 article pages.

- [ ] **Step 4: Commit**

```bash
git add deploy.sh nginx.conf.example
git commit -m "feat: deploy script and nginx config for blog.icmoc.com"
```
