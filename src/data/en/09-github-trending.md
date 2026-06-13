---
title: "Building github-trending: From a Cron Script to a React App"
date: 2026-06-13
tags: [Open Source, API, React, DevEx]
excerpt: "I wanted to track what was rising on GitHub each week without manually scrolling. A Node.js script became a full React app — here's what that journey looked like."
draft: false
---

Every Monday morning I'd open GitHub's trending page, skim the top repos, and try to remember what looked new versus what had been sitting there for weeks. The page mixes everything together — repos trending today, this week, this month — and gives you no way to filter, export, or compare across time. After a few months of this I stopped trusting my own memory and started writing it down.

The first version was twelve lines of JavaScript.

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

That's the heart of it. The GitHub Search API accepts a `created:>=` qualifier, so you can ask for repos created in the last seven days, sorted by stars. It's not exactly "trending" in GitHub's own sense — but it's a proxy that's good enough. Repos that go from zero to hundreds of stars in their first week are the ones worth watching.

The script saved results to `docs/YYYY/MM/date.json` and a matching CSV, then I set it on a cron job to run every Sunday night.

```bash
0 21 * * 0 cd /path/to/github-trending && node index.js
```

That worked for about three months. I had a directory of JSON files accumulating, which I'd open in VS Code and search through. Not ideal. When I wanted to compare what was trending in January versus March, I was manually diffing files.

## The UI wasn't optional anymore

The data collection was solved. Exploring it wasn't.

I built the React app mostly because I wanted two things the raw files couldn't give me: a table with sortable columns, and a way to filter by language or topic without writing a grep command. Ant Design 5 handled most of the table work — `Table`, `Input`, `Select`, the standard toolkit. The interesting UI problem was the dual view mode.

Researchers and developers use the data differently. A developer scanning for something to star wants cards — repo name, description, star count, one click to the URL. A researcher or analyst comparing many repos at once wants a dense table with all twenty fields visible. I built both views and let users switch between them, with the same underlying dataset.

```
Card view  → visual browsing, one repo per card
Table view → data analysis, all fields visible, sortable, filterable
```

The fields you can display are the full set the GitHub API returns: name, owner, avatar, description, topics, license, all the URL variants, created/updated/pushed dates, stars, forks, open issues, size, primary language. Twenty-plus attributes. Most people use maybe six.

## The rate limiting problem

GitHub's Search API caps unauthenticated requests at 10 per hour. With a personal access token and `public_repo` scope, that goes to 30 per hour — still not a lot if you're paginating through results aggressively.

My initial approach was to fetch everything on page load. That hit the rate limit inside a day of showing the app to colleagues. The fix was two things: cache aggressively on the client side using `localStorage`, and add explicit feedback when the rate limit kicks in rather than silently returning an empty response.

The settings panel stores the token, display field selection, and page size in `localStorage`. Nothing goes to a server. The token never leaves the browser. That was a deliberate choice — I didn't want to run a backend just to proxy GitHub API calls, and I didn't want to ask users to trust me with their credentials.

## What got interesting

The query design took a few iterations.

The naive version used GitHub's own trending endpoint. Except that endpoint isn't part of the official API — it's a scrape target that changes without notice and blocks unusually frequent access. I'd used it in an earlier version and got burned when GitHub quietly restructured the page markup.

Switching to the Search API with `created:>=YYYY-MM-DD` was more reliable, but it measures something different. A repo created two years ago that suddenly gets attention won't appear. That's a tradeoff I decided to accept. The point of the tool was discovery — new things rising fast — not monitoring existing repos for sudden spikes.

The output formats matter more than I expected. I thought JSON would be enough. Then a PM asked for a spreadsheet. CSV export via `papaparse` took an afternoon and removed about four "can you export this for me?" requests per month.

## Where it sits now

The web app is live at [github.ranbot.online](https://github.ranbot.online). The cron script still runs every Sunday. The `docs/` directory has almost two years of weekly snapshots now, which I keep meaning to turn into something more interesting — trend lines, language shifts over time, that kind of thing.

The project didn't start with a clear scope. It started with me being annoyed at a manual process. That's still the most reliable source of tools worth building.
