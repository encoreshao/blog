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

1. Open with a moment, not a thesis. A real scene: what you were doing, what broke, what you were asked for. Drop the reader into the story before you explain what the story is about.
2. Tell what actually happened, in the order it happened. Skip the parts that aren't interesting.
3. Go deep on the one or two things that were genuinely hard or surprising. This is the payload.
4. End with what changed — in the code, in your thinking, or in how the team works. Not a summary, not a list of takeaways.

**Writing rules:**

- Write sentences the way you'd say them out loud. Read each paragraph back to yourself. If it sounds like a report, rewrite it.
- Short sentences land harder than long ones. Use them for the moments that matter.
- Vary rhythm. A short sentence after a long one hits different. Use it deliberately.
- Never start with a definition ("Redis is an in-memory data store…"). Never end with a call to action ("I hope this helps!").
- Cut every word that doesn't add meaning. "Very", "really", "quite", "in order to", "it's important to note" — all gone.
- Name the thing. Don't write "a popular framework" when you mean Rails. Don't write "I encountered an issue" when you mean "the migration wiped the staging DB."
- One idea per paragraph. If you're explaining two things, that's two paragraphs.
- Include code blocks only when seeing the code changes what the reader understands. Not as decoration.

**Banned phrases (any AI-flavored language that signals the writer is a machine):**

> "In today's fast-paced world", "game-changer", "leverage", "robust", "seamless", "dive deep", "let's explore", "it's worth noting", "at the end of the day", "moving forward", "in conclusion", "this is a great opportunity", "the good news is", "the bad news is", "this is a complex topic", "I hope this was helpful", "delve", "unlock", "unleash", "transformative", "cutting-edge", "empower", "in summary", "to summarize"

If any of these appear in a draft, remove and rewrite the sentence from scratch.

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

### 7. Save the Files

Save both files:

- `src/data/en/<NN>-<slug>.md`
- `src/data/zh/<NN>-<slug>.md`

Use the **same** `NN` and `slug` for both files.

### 8. Confirm

Report back to the user with:
- The two file paths created
- The article title in EN and ZH
- A one-sentence summary of what the article covers

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
