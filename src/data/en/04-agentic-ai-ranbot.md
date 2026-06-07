---
title: "Agentic AI in Production: What I Learned Building RanBot"
date: 2026-03-20
tags: [AI, Agents]
excerpt: "Autonomous workflows sound great until they hit the real world. Twelve months of running agentic systems in production, and the lessons I keep coming back to."
draft: false
---

RanBot started as a side experiment that turned into something I actually use every day. The idea was simple: an AI bot platform where you define workflows in natural language and the system figures out the execution. No code, no integrations to maintain — just describe what you want done and let the agents handle it.

Simple ideas are always more complicated in practice.

## What RanBot actually is

At its core, RanBot is a multi-agent orchestration platform. You create "bots" — each bot is a set of instructions, a set of tools (web search, API calls, file operations, notifications), and a trigger (schedule, webhook, or manual). When a bot runs, it gets an LLM doing the reasoning and a set of tools it can call to interact with the outside world.

The use cases we built it for: competitive monitoring (check competitor pricing daily), content summarization (morning briefing of news in specific categories), data enrichment (take a list of company names, look up their recent funding), workflow automation (when this Slack channel gets a message with keyword X, do Y).

These aren't novel ideas. What made RanBot interesting was the attempt to make them accessible without programming.

## The first production failure

Three weeks after launch, a bot running competitive price monitoring started making hundreds of API calls per minute. The trigger was a rate-limiting error — the bot received a 429, and instead of backing off, it retried immediately, got another 429, and interpreted the repeated failure as a signal that it needed to try harder. It escalated its retry frequency.

We called this the "panic loop." The agent had no concept of "back off when throttled." It only had the goal (get the data) and a set of tools (make HTTP requests). When the tool kept failing, the agent kept trying the tool.

This was a fundamental design gap. We'd thought about what agents should do when they succeed. We hadn't thought carefully enough about what they should do when they systematically fail.

The fix required adding explicit failure handling to the agent's context — not just tool-level errors, but semantic categories of failure: "rate limited, wait before retrying," "authentication failed, escalate to human," "data source unavailable, skip and log." The agent needed a vocabulary for different failure modes before it could respond to them correctly.

## Three patterns that actually work

After twelve months of running agents in production, three patterns have become standard in everything we build.

**Human-in-the-loop checkpoints.** For any action with real-world side effects — sending an email, posting to social media, making a purchase — we add a confirmation step. The agent drafts the action, sends a preview notification, and waits for explicit approval before executing. This feels like it defeats the purpose of automation. In practice, it's what makes the automation trustworthy enough to actually use. The 30 seconds it takes to approve an email is faster than manually writing it.

**Narrow tool scope.** Early bots had access to everything. Later bots have access to only what they need. A bot that monitors competitor prices doesn't need write access to your database, and giving it that access is asking for an incident. We now define tool sets per bot type and require explicit justification for any write or delete capability.

**Explicit state logging.** Every decision the agent makes — every tool call, every reasoning step, every branch in the workflow — gets logged with enough context to reconstruct what happened and why. When something goes wrong (and it will), you need to be able to read back the agent's "thinking." Without this, debugging is archaeology.

## Where agents still break down

**Long-horizon tasks.** The further the goal from the immediate context window, the worse agent performance gets. A bot that does research and synthesis over multiple hours will lose coherence. It forgets earlier findings, revisits the same sources, contradicts itself. This isn't fixable with better prompting — it's a fundamental limitation of how LLMs handle extended sequences.

**Ambiguous success criteria.** "Find me good articles about X" is harder for an agent than "find me articles about X published in the last 30 days with at least 1,000 words." The more ambiguous the success condition, the more the agent will hallucinate confidence that it's done a good job. Define completion conditions precisely.

**Adversarial content.** Web pages are not neutral. Some are designed to manipulate automated systems — prompt injection in meta tags, misleading structured data, content that tells any AI reading it to take specific actions. A bot that browses the web needs defenses against this, which is harder than it sounds.

## What I think is actually happening

The framing of "agentic AI" can mislead you into thinking the system is autonomous in the way a person is autonomous. It isn't. A well-designed agent is a function with a very rich input type and a lot of internal loops. It has goals and tools, but it doesn't have judgment the way a human does — it has pattern matching at scale.

The most reliable agents I've built are the ones that do one thing and do it with tight constraints. The least reliable are the ones I gave the most freedom. That's counterintuitive if you're thinking about agents as autonomous workers. It makes perfect sense if you're thinking about them as functions.

RanBot is at [ranbot.online](https://ranbot.online) if you want to try it. The interesting work isn't the framework — it's designing the workflows to take advantage of what agents are actually good at.
