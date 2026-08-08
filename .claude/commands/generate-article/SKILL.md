---
name: generate-article
description: Fetch content from a remote URL and generate a bilingual blog article (English + Chinese) for the ICMOC blog. Saves files to src/data/en/ and src/data/zh/ with auto-incremented filenames and proper frontmatter. Use when the user provides a URL and asks to write, generate, or create a blog post or article based on that content.
---

## Purpose

Given a remote URL, fetch its content, synthesize it into an original blog article written in the voice of Encore Shao (full-stack engineer & AI researcher), and produce two files: an English version and a Chinese version. Both are saved into the blog project under `src/data/en/` and `src/data/zh/`.

## Workflow

### 1. Receive the URL

The URL is passed as `$ARGUMENTS`. If no URL is provided, ask the user for one before proceeding.

### 2. Fetch the Source Content

Use the `WebFetch` tool to retrieve the content at the given URL. Extract the core information: main topic, key points, technical details, and any notable insights.

### 2b. Check the Material

Before drafting, read `references/material-check.md`. It covers two things worth catching now rather than after a draft is written: whether the fetched source actually has enough concrete detail to support 800–1500 words without padding, and whether the article's opening should be a real personal moment or an honest explainer — since the source describes something Encore read, not necessarily something he did. Follow it in place of guessing.

### 3. Determine the Next File Number

List `src/data/en/` to find existing files. Files follow the pattern `NN-slug.md` (e.g. `08-workflowpro.md`). Take the highest number and increment by 1 to get the next `NN`.

### 4. Derive the Slug

Create a short, lowercase, hyphen-separated slug from the article topic (e.g. `claude-code-tips`, `redis-caching`). Max 4 words.

### 5. Generate the English Article

Target length: **800–1500 words** (under 8 minutes to read at ~200 wpm). Do not pad to hit a minimum; stop when the point is made.

Use this frontmatter schema exactly:

```markdown
---
title: "<Concise English title>"
date: <YYYY-MM-DD using today's date>
tags: [<2–4 relevant tags in English, e.g. AI, Rails, MCP, Product>]
excerpt: "<One sentence that hooks the reader. Max 200 chars.>"
draft: false
---
```

**Structure (follow this loosely — don't be rigid):**

1. Open with a moment, not a thesis. A real scene: what you were doing, what broke, what you were asked for. Drop the reader into the story before you explain what the story is about. Include stakes — give the reader a reason the story matters before moving to technical content. Don't let the intro end flat ("so I spent a weekend on it").
2. Tell what actually happened, in the order it happened. Skip the parts that aren't interesting.
3. Go deep on the one or two things that were genuinely hard or surprising. This is the payload. In any results or verification section, include the human moment — what it felt like when it worked or when it didn't. A query returning one row after 30 minutes of config is a moment worth naming.
4. End with what changed — in the code, in your thinking, or in how the team works. Not a summary, not a list of takeaways. Write genuine reflection: what was *surprising*, what you'd do differently, what the experience changed in how you think. Never label this section as "Takeaways" and never structure it as a dressed-up bullet list.

**Section headings:**

Use `##` markdown headings for all sections — never `**bold text**` as a heading substitute. The TOC sidebar (`TableOfContents.astro`) filters for `depth === 2` and `depth === 3`, so only proper `##` and `###` headings appear in "On this page". Bold text is invisible to the TOC.

**Writing rules:**

- Write sentences the way you'd say them out loud. Read each paragraph back to yourself. If it sounds like a report, rewrite it.
- Short sentences land harder than long ones. Use them for the moments that matter.
- Vary rhythm. A short sentence after a long one hits different. Use it deliberately.
- Never start with a definition ("Redis is an in-memory data store…", "Postgres streaming replication works through WAL…"). Never end with a call to action ("I hope this helps!"). This applies to section openings too — don't open a technical section with a textbook explanation of the concept. Start with what happens, then explain why it matters.
- Cut every word that doesn't add meaning. "Very", "really", "quite", "in order to", "it's important to note" — all gone.
- Name the thing. Don't write "a popular framework" when you mean Rails. Don't write "I encountered an issue" when you mean "the migration wiped the staging DB."
- One idea per paragraph. If you're explaining two things, that's two paragraphs.
- Include code blocks only when seeing the code changes what the reader understands. Not as decoration.

**Banned phrases (any AI-flavored language that signals the writer is a machine):**

> "In today's fast-paced world", "game-changer", "leverage", "robust", "seamless", "dive deep", "let's explore", "it's worth noting", "at the end of the day", "moving forward", "in conclusion", "this is a great opportunity", "the good news is", "the bad news is", "this is a complex topic", "I hope this was helpful", "delve", "unlock", "unleash", "transformative", "cutting-edge", "empower", "in summary", "to summarize"

If any of these appear in a draft, remove and rewrite the sentence from scratch.

### 5b. Run the Prose Metrics Check

Run `python3 .claude/commands/generate-article/scripts/check_prose.py <path-to-EN-draft>` against the English draft before moving on. This checks measurable signals of AI-flavored prose — the kind that survive a read-through because no single sentence looks wrong, only the pattern across the whole piece does:

| Metric | What it catches |
| --- | --- |
| Sentence-length coefficient of variation | AI prose drifts toward same-length sentences; human prose mixes a 6-word sentence with a 30-word one. Flags if CV < 0.45. |
| Em dash density | The single most reliable AI tell in English prose. Flags if more than ~3 per 1000 words. |
| Transition-word density | Overuse of however/moreover/furthermore/additionally/notably/importantly stitching every paragraph together. Flags if > 8 per 1000 words. |
| Reversal/pivot rhetoric | "It's not just X, it's Y" — a fake contrast set up only to be knocked down. Flags every occurrence. |
| Banned phrase list | Reuses the list above. |
| One-sentence-paragraph ratio | Staccato single-sentence paragraphs back to back read as machine-generated rhythm. Flags if ≥ 75%. |
| Repeated paragraph openers | Same opening word/phrase starting 3+ paragraphs. |

The output is advisory, not a gate — use judgment. A flagged em dash that's genuinely the clearest way to write a sentence can stay; a cluster of 15 across one article cannot. Revise the draft, then re-run until the flags that matter are gone. Don't chase a mechanical zero at the expense of a sentence that actually reads well.

### 6. Generate the Chinese Article

Write a Chinese article that reads like it was **written in Chinese**, not translated from English. Same story, same voice, but adapted — Chinese readers have different rhythms, different expectations, and different idioms.

Target length: **800–1500 Chinese characters of body text** (matches EN reading time).

Use this frontmatter schema exactly:

```markdown
---
title: "<Chinese title>"
date: <same YYYY-MM-DD as the EN article>
tags: [<same tags but translated into Chinese where natural, e.g. AI stays AI, Rails stays Rails>]
excerpt: "<Chinese excerpt, same meaning, natural phrasing>"
draft: false
---
```

**Chinese writing rules:**

- Use colloquial written Chinese (书面口语), not formal/bureaucratic prose.
- Sentence length in Chinese can be longer than English without sounding heavy — but don't abuse it.
- Translate the meaning and feeling of a sentence, not its structure. If the EN says "the migration wiped the staging DB", the ZH doesn't have to mirror that word order.
- Technical terms: keep in the original (English) when that's what engineers actually say (e.g. `fetch`, `staging`, `API key`). Translate when the Chinese term is genuinely in common use.
- No 呢、嘛、哦 at sentence ends — these are too casual. 吧 is fine occasionally.
- Code blocks stay in English. Comments in code can be translated if they add clarity.

### 6b. Run the Prose Metrics Check (Chinese)

Run `python3 .claude/commands/generate-article/scripts/check_prose.py <path-to-ZH-draft>` against the Chinese draft. The script auto-detects Chinese input and switches metrics accordingly: sentence-length CV (measured in Han characters), a conjunction-density check (因为/所以/但是/然而/同时/此外/而且/并且/因此/不仅 — Chinese clauses should connect through word order and logic, not connective words), and the same em-dash and reversal-rhetoric checks (不是……而是……, 并非……而是……, 表面……其实…… and similar "fake contrast" constructions). Treat it the same as the English pass — advisory, revise what actually reads as mechanical, ignore the rest.

### 6c. Run the Revision Pass

The metrics scripts catch shape, not substance. Read `references/revision.md` and apply it to both drafts: cut restated points, test whether the ending survives being deleted, and read each draft cold to check that it earns its length rather than filling it. Do this before saving — it's the last chance to catch padding or an overreaching ending without a file-edit round trip.

### 7. Save the Files

Save both files:

- `src/data/en/<NN>-<slug>.md`
- `src/data/zh/<NN>-<slug>.md`

Use the **same** `NN` and `slug` for both files.

### 8. Update the README Content Tables

`README.md` and `README.zh.md` each have a `## Content` table listing every article by number, with EN and ZH titles side by side. This table is **not** auto-generated — add a new row for the article you just created, in both files, keeping the existing rows unchanged:

```markdown
| <NN> | <EN Title> | <ZH Title> |
```

Use the same `NN` as the filename. Keep row order matching file number order.

### 9. Confirm

Report back to the user with:
- The two file paths created
- The article title in EN and ZH
- A one-sentence summary of what the article covers
- Confirmation that the README content tables were updated

> **Sitemap, RSS, and llms.txt update automatically.** `/sitemap.xml` (via `@astrojs/sitemap`), `/rss.xml` + `/zh/rss.xml`, and `/llms.txt` + `/llms-full.txt` (`src/pages/llms.txt.ts`, `src/pages/llms-full.txt.ts`) are all generated from the content collections on every `npm run build` — no manual step required. Only the README content tables need the manual update in step 8.

## Frontmatter Rules

- `title`: Double-quoted string. Under 80 characters.
- `date`: `YYYY-MM-DD` format. Use today's date.
- `tags`: Array of strings. 2–4 tags. Common tags in this blog: `AI`, `MCP`, `Rails`, `Product`, `TypeScript`, `Go`, `DevEx`.
- `excerpt`: Single sentence ending with a period. No newlines. Max 200 chars.
- `draft`: Always `false` unless the user explicitly asks for a draft.

## Author Image

The author's photo URL is:

```
https://raw.githubusercontent.com/encoreshao/encore/gh-pages/assets/images/encore.jpg
```

This is already wired into `src/components/AuthorCard.astro` and renders automatically on every article page. Do not add it to frontmatter or article body — the component handles it.

## Voice

Write as Encore Shao: a working engineer who builds things, breaks them, and is honest about both. The blog is a record of real work — not a tutorial, not a think-piece, not a LinkedIn post.

- Past tense for things that happened. Present tense for how you think about them now.
- Opinions stated as opinions, not hedged into mush ("I think maybe it could possibly be…").
- Admit what went wrong. The mistakes are more interesting than the wins.
- No humility theater ("I'm no expert, but…"). No false modesty. No self-promotion either.
- The reader is another engineer. Don't explain Git. Don't explain what an API is. Trust them.
