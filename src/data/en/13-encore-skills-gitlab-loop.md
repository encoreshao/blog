---
title: "encore-skills: Stop Re-Teaching Your AI"
date: 2026-07-29
tags: [AI, DevEx, GitLab, Product]
excerpt: "I kept re-teaching the same GitLab workflow to Claude Code, Cursor, and Codex, until an MR shipped with no issue number linked — so I built one skills library that talks to all three."
draft: false
---

It was a Friday afternoon and I had three terminals open. Claude Code on one client's repo, Cursor on another, Codex wired into a third project's CI. Same job in all three: read a GitLab issue, find the root cause, branch, fix it, review it, open an MR. I'd written the instructions for that loop three separate times, in three separate formats — a `CLAUDE.md`, a set of `.cursor/rules/*.mdc` files, an `AGENTS.md` — because each tool wants its process definition in its own shape.

I tweaked the MR title convention that week. Titles needed the issue number now: `fix: #482 nil check on webhook payload`, not just `fix: nil check on webhook payload`. I updated `CLAUDE.md`. I forgot the Cursor rules. An MR went out three days later with no issue number in the title, and a reviewer on that project asked which ticket it closed. Small thing. Also exactly the failure mode you get when the same process lives in three places and only one of them is current.

## What I actually built

The fix wasn't "be more careful next time." It was: stop maintaining three copies of the same process. `skills/` became the single source of truth — one `SKILL.md` per skill, plain markdown with frontmatter, no tool-specific syntax. Then three adapters:

```bash
./scripts/setup-claude.sh   # symlinks into ~/.claude/skills/
./scripts/setup-cursor.sh   # generates .cursor/rules/*.mdc
./scripts/setup-codex.sh    # generates AGENTS.md
```

Edit a skill once, regenerate the adapters, commit both. The repo dogfoods itself — its own `CLAUDE.md`, `AGENTS.md`, and `.cursor/rules/` are generated from its own `skills/` directory, so whichever tool I'm using to work on the skills library is itself using the skills.

Ten skills came out of this, split into two loops.

## The two loops

The first is for PMs and designers, and it assumes zero codebase access:

```
write-issue → share → gather-feedback → refine → validate → finalize
      ↑                      |
      └───────── iterate ────┘
```

`write-issue` turns a rough idea into a structured GitLab issue. `pm-workflow` runs the rest — share it, gather feedback from users and stakeholders, refine, validate, loop back if it's not there yet. It's done when an engineer can pick the issue up and start without asking a single clarifying question. That's the actual gate, not "the issue has a title and a description."

The second is the one that bit me with the MR title bug:

```
write-issue → analyze-issue → fix-issue → review-code → create-mr → [merge]
      ↑                                                                 |
      └──────────────────────── new issue from feedback ────────────────┘
```

`eng-workflow` runs this as a single guided session, phase by phase, and each phase has a gate that has to be true before the next one starts: root cause identified before you write code, the problem confirmed gone (not just tests green) before you call it done, verdict "ready to merge" with no open blockers before `create-mr` runs, and the MR targeting the branch you actually came from before it opens. `summarize-issue` and `triage-issue` sit off to the side of the main loop — one posts a recap once the MR exists, the other replies to comments on an issue that's already in flight.

## Installing it

Skills live in one repo and get adapted per tool with a single install script:

```bash
# Claude Code — CLI, Desktop, and IDE extensions
curl -fsSL https://raw.githubusercontent.com/encoreshao/encore-skills/main/scripts/setup.sh | bash -s -- --claude

# Cursor — run inside the project you want it in
cd /your/project
curl -fsSL https://raw.githubusercontent.com/encoreshao/encore-skills/main/scripts/setup.sh | bash -s -- --cursor

# Codex — also run inside the project, generates AGENTS.md
cd /your/project
curl -fsSL https://raw.githubusercontent.com/encoreshao/encore-skills/main/scripts/setup.sh | bash -s -- --codex
```

Every one of those one-liners clones (or updates) a checkout to `~/.encore-skills` on its own — there's no separate `git clone` step regardless of which tool you're installing for. Running the same command again later upgrades in place.

## Wiring up GitLab, once

Every skill that talks to GitLab reads from the same config, so this only needs doing once per machine. From Claude Code, after restarting it post-install:

```
/gitlab-config
```

It walks you through adding your GitLab instance URL and a personal access token with `api` scope. From Cursor or Codex, the equivalent is just asking in plain language — "run the gitlab-config skill to set up my GitLab access" — since there's no slash-command layer in those tools. Multiple GitLab instances (a self-hosted one for work, gitlab.com for an open-source side project) live in the same config file under separate names, and every skill picks the right one from the project you're standing in.

## Using it

Day to day this looks less like running a tool and more like saying what you have. Drop into a project with an open issue and say `analyze this issue` or `/eng-workflow #482` — the skill figures out from context whether you're starting fresh or picking back up mid-loop. Same sentence works in Claude Code, Cursor, or Codex, because the skill definition is the same file underneath all three; only the wrapper reading it differs.

## The part that took longest to get right

The easy version of `create-mr` just assumes every branch targets `main`. That breaks the moment a team branches off `staging` or `develop`, which is common enough on client projects that I hit it in the first week of dogfooding. The fix touches two skills, not one: `fix-issue` checks what branch you were on before it cuts `<type>/<issue-number>-<func-name>`, and records that originating branch. `create-mr` reads it back and targets the MR there instead of guessing `main`. Neither skill can solve this alone — the information has to survive the handoff between them, which is a different problem than either skill's own logic.

The other piece I underestimated was memory. `analyze-issue` and `triage-issue` both need to know things about a GitLab project — who's on it, what an issue's comment history looks like, what I concluded last time I analyzed something similar. Without a cache, every run re-fetches and re-derives that from scratch, which is slow and, worse, means an issue's comment thread from an hour ago doesn't inform the reply I'm drafting now. So `gitlab-config` grew a local cache under `~/.gitlab/cache/`, layered by instance, group, project, and issue. The `sync-issue` command still calls the GitLab API every time — new comments are never missed — but merges onto whatever's already cached, matching by note id, instead of discarding history and starting over. A group like `acme/rocket` holding both `rocket-web` and `rocket-mobile` gets its team roster synced once and shared across both projects, instead of fetched twice.

## Watching it actually work

The moment that told me this was working wasn't a demo. It was running `triage-issue` against a real issue with eleven comments, most of them not addressed to me. The skill correctly picked out the two that tagged me directly, ignored a back-and-forth between two other engineers that didn't need my input, and drafted replies grounded in the actual current state of the code — not a guess, an actual read of the file the comment was asking about. I'd expected to spend twenty minutes editing the drafts down. I spent two, mostly changing tone in one sentence.

The other one was smaller but stuck with me more. `create-mr` pulled up the issue thread, found a comment from three weeks earlier linking a related MR that had already fixed half the problem, and added a "Related" section to the description pointing the reviewer at it. I hadn't told it to look for that. It read the thread because the skill says to, and found something I would have had to remember was there.

## What actually changed

I went in thinking the hard problem was getting an AI agent to write correct code and open a clean MR. That part turned out to be the easy part — all three tools are perfectly capable of following a well-written process. The actual problem was that I'd never written the process down in a form that survived being copied between tools. Every tweak to "how we open an MR" or "when to reply to a comment" lived in my head, got typed into whichever tool I happened to be using that day, and drifted from the other two within a week.

A `SKILL.md` file forces the process into something explicit enough to be portable, and portable enough that fixing it once actually fixes it everywhere. That's a smaller idea than "AI writes your code for you," and it's the one that's held up after a month of using this on real client work. `encore-skills` is on GitHub at [github.com/encoreshao/encore-skills](https://github.com/encoreshao/encore-skills), MIT licensed, install script included.
