---
title: "AI-Powered Bookmark Dashboard: A Chrome Extension Story"
date: 2026-04-15
tags: [AI, Chrome]
excerpt: "Replacing the new tab page with something actually useful — how I built a bookmark dashboard powered by agentic AI, and what I'd do differently."
draft: false
---

I have 800 bookmarks. Most of them are useless. But somewhere in that pile are links I saved with genuine intention — documentation I wanted to read, tools I meant to try, articles I was going to come back to. Every time I opened a new tab and saw Chrome's default page, I was reminded that those 800 links existed and that I was doing nothing with them.

The Bookmark Dashboard started as a frustration project. Six months later it's a real extension on the Chrome Web Store, and building it taught me more about the state of browser extension development than I expected.

## The idea

The pitch is simple: replace the new tab page with a full-featured bookmark manager. Every bookmark, immediately accessible. Search, tags, folders, pinned items — all without opening a separate app or going to the bookmarks menu.

The AI layer came later. Once you have access to a user's entire bookmark library in a single JavaScript context, AI starts to become genuinely useful:

- **Duplicate detection**: find bookmarks with the same URL or near-identical titles
- **Dead link cleanup**: check which URLs return 404 or have changed
- **Tag suggestions**: analyze page content and suggest relevant tags
- **One-click reorganization**: propose a better folder structure based on content

This is "AI-powered" in the real sense — the AI does actual work that would be tedious to do manually, not just surfaces a chatbot.

## Architecture decisions

Chrome extensions have a peculiar programming model. You have three distinct execution contexts:

- **Background service worker**: runs persistently (or on demand), has full Chrome API access, no DOM
- **Content scripts**: injected into web pages, have DOM access, limited Chrome API access
- **Extension pages** (popup, new tab override, options): regular web pages with Chrome API access

The new tab override lives in the extension page context, which means you get a full React app running on every new tab. I chose React 18 for the UI and TypeScript throughout — not because it was necessary, but because the bookmark library manipulation code gets complex quickly and types catch the bugs that would otherwise surface as "the dropdown shows the wrong folder."

The AI features use Claude's API via the background service worker. Direct API calls from the extension page would expose the API key in network requests — background proxies the calls so the key only lives in the extension's storage.

## What Chrome makes hard

Manifest V3 (the current extension platform) is significantly more restrictive than V2. Service workers don't persist — they start on demand and shut down after inactivity. Any state you need to survive a service worker restart has to go to `chrome.storage`.

The most annoying constraint: you can't make arbitrary network requests from a service worker to check if URLs are alive. Chrome's declarative content policy blocks most outbound fetch calls by default. I had to use the `offscreen` API — a V3 feature that creates an off-screen document — to run URL validity checks through a DOM `fetch`. It's a roundabout workaround that adds complexity for a straightforward use case.

Folder operations in the `chrome.bookmarks` API are also surprisingly limited. You can move bookmarks, but bulk operations require looping with individual API calls — there's no batch move. For a user with 800 bookmarks, reorganizing a folder is noticeably slow.

## The feature nobody asked for vs the one everyone uses

I spent the most time on the AI reorganization feature — the one that analyzes your bookmark structure and proposes a better folder hierarchy. It's technically the most interesting part of the codebase.

Almost nobody uses it.

The feature everyone uses is basic search. Full-text search across all 800 bookmarks, returning results as you type, with keyboard navigation. It took me two days to build. It's the first thing people mention in reviews.

This is the classic product lesson: the feature that solves a daily friction point beats the feature that solves an occasional big problem. Reorganizing bookmarks is something you do once a year. Searching for a bookmark is something you do multiple times a day.

## What I'd do differently

**Better offline handling.** The AI features require network access, but search and basic management should work offline without degradation. I didn't think about this until users on airplane mode reported broken experiences.

**Sync between browsers.** The tag layer is stored in extension storage, which doesn't sync to Chrome Sync by default. Users who switch between their laptop and desktop find their tags missing on the second machine. `chrome.storage.sync` has a 100KB limit — plenty for most users — but I initially used `chrome.storage.local` without thinking about cross-device use.

**Test the performance edge cases earlier.** My development machine has 200 bookmarks. The first user who installed with 3,000 bookmarks told me the new tab page took four seconds to load. I had to rethink the rendering approach to virtualize the list.

The extension is on the Chrome Web Store and the source is at [github.com/encoreshao/bookmark-dashboard](https://github.com/encoreshao/bookmark-dashboard). Try it if you've ever looked at your bookmarks bar and felt vaguely guilty about the mess.
