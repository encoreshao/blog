---
title: "More Than a Decade Building a VC Intelligence Platform"
date: 2026-06-24
tags: [Rails, Product, AI, Infrastructure, VC]
excerpt: "What it actually takes to build a venture capital intelligence platform — data quality problems, 30+ integrations, and the infrastructure that makes it run at 3am."
draft: false
---

The first time the meeting prep feature worked end-to-end, it was 6:58am on a Tuesday. A Slack notification appeared in a channel before anyone arrived at the office. It had the company name, the funding history, the headcount trend, the LinkedIn relationship chain between the founders and the investment team, and a note from a call logged in Salesforce fourteen months earlier. No one assembled it. No one asked for it. The system ran on a schedule, pulled from six different sources, packaged everything into a document, and posted it automatically.

I'd been building toward that moment for two years. The calendar integration, the relationship graph, the entity data pipeline, the Slack bot — each piece had existed separately before that morning. Getting them to work together, end-to-end, without breaking anything, was not something I took for granted.

## How We Got Here

We came in as a technology partner. The firm had a deal-sourcing problem — not a shortage of signals, but a surplus of disconnected ones. Data lived in a CRM that didn't talk to email. LinkedIn sat in one tab. Crunchbase in another. Someone's notes from a founder call were in a notebook somewhere.

Our job was to simplify that workflow, improve data quality, and eventually introduce AI where it could actually help. That turned out to be a decade-long engagement.

## What We Built

The short version: a deal-sourcing and relationship intelligence platform for a venture capital firm.

The longer version: a shared Rails engine running in the background, watching thousands of companies, pulling data from 30+ sources, and building a picture of each company that the investment team can actually use. It powers six applications — the main web interface, a dedicated API, an inbound pipeline, pipeline review tooling, a data warehouse, and an OAuth service. All of them share the same data layer.

The analysts who use it every day don't see any of this. That's the point.

## The Company Identity Problem

The hardest thing I had to design wasn't any individual integration. It was a more fundamental problem: every data source has a different opinion about the same company.

LinkedIn says a company has 250 employees. Crunchbase says 180. ZoomInfo says 310. SimilarWeb shows declining web traffic. Apptopia shows surging mobile downloads. They're all looking at the same company. They all disagree.

The solution I built is what I call the Entity–Profile–Site triangle. An Entity is the canonical record for a company — one row, one domain name, one source of truth. A Profile is what a specific Site (a data source) says about that company. Crunchbase has its own profile for the company. LinkedIn has its own. Each holds raw JSONB data from that source, unmodified.

Once a day, or whenever a profile updates, a derived data pipeline runs. It reads all the profiles for an entity, applies source-specific weights, blends time-series data, and writes a single `derived_data` column that downstream features can query against.

Getting the aggregation logic right took years. The database has grown to over 800 migrations and roughly 300 tables. I index into that JSONB column with expression-based GIN indexes so analysts can filter on deeply nested metrics without watching a spinner for several seconds.

## Background Workers at Scale

The data doesn't arrive. We go and get it.

At any given time in production there are 27+ Sidekiq processes running, each owning specific queues. Every data source has its own job namespace: `Crunchbase::*`, `LinkedIn::*`, `Salesforce::*`, `Office365::*`, `Notion::*`, and on from there.

Every source follows the same lifecycle: a scheduler fires a discovery job, that job calls the source's API client, raw data lands in a Profile, the system checks whether the profile already belongs to an Entity — and if not, fuzzy-matches it to one — derived data recomputes, features and scores update.

What makes this reliable at scale is the unglamorous infrastructure around it. Rate limiters back off and retry when LinkedIn returns a 429. Redis-based single-thread locks prevent concurrent jobs from clobbering the same entity. A deduplication key blocks a job from running twice in the same day against the same target. Over the years this became a layered concern stack — job deduplication, throttling, single-thread execution, and credential rotation — that jobs compose by including the right modules.

None of this shows up in a changelog. It's why the system runs at 3am without supervision.

## The People Problem

Companies don't make decisions. People do.

The platform tracks individuals — founders, executives, investors — across their career history, LinkedIn connections, email interactions, and relationship history with the investment team. The identity resolution problem here is genuinely hard. "John Smith, CEO at Acme Corp" in LinkedIn might be the same person as "Jonathan Smith" in Salesforce and "J. Smith" in an Office365 contact. I built four merge strategies to handle this: by email, by nickname and alias, by cross-email match, and by fuzzy name similarity.

When it works, the investment team can see that a colleague had coffee with this founder two years ago, and another colleague is a first-degree LinkedIn connection to the CTO. That's the difference between a cold email and a warm introduction.

## The Integration That Aged My Hair

Out of 30+ integrations, Salesforce is the one I could write a separate article about.

Bi-directional sync sounds manageable in a design doc. In practice it means: entities push to Salesforce accounts, Salesforce contacts get pulled back as people profiles, task completions sync in both directions, account ownership changes propagate across both systems — all while users are actively editing records in both places simultaneously.

I built a "dispatch center" pattern to orchestrate sync operations without triggering infinite update loops. Seven years in, it still produces new edge cases. I've made peace with that.

## When AI Showed Up

For most of the platform's life, the intelligence was structural — funding signals, headcount growth, web traffic trends, review counts. Around 2022 we started layering in LLMs, and it changed what "useful" actually meant.

The meeting prep feature I opened with is the clearest example. The night before a scheduled meeting, a job pulls the calendar event, identifies which company or person is involved, assembles everything the platform knows about them — funding history, headcount trend, recent news, relationship context — runs it through an LLM, and posts a briefing to Slack before the team walks in the door. No one schedules it. No one writes it. The AI does the synthesis; the structured data gives it something accurate to work with.

That was the pattern for every AI feature we built: the model handles language, the pipeline handles truth.

**Chatbot Q&A.** Analysts can ask natural-language questions about any company in the database — "what's their hiring trend in engineering?" or "who on our team knows someone there?" — and get answers drawn from live structured data, not a static document. The interface is conversational; the answers are grounded.

**AI-drafted outreach.** When the investment team wants to reach a founder, the system drafts an opening email using relationship context: shared connections, prior interactions, the company's recent milestones. The analyst edits and sends. The AI handles the first draft so the human can focus on the actual relationship.

**LLM narrative summaries.** Every entity profile now includes an AI-generated paragraph synthesizing the structured data into readable prose — what the company does, how it's been growing, what makes it notable right now. This lives alongside the raw metrics, not instead of them.

**RAG retrieval with pgvector.** Investment memos, call notes, and Notion documents are embedded and stored as vectors. When a user asks a question, the system retrieves the most semantically relevant chunks before generating a response — grounding answers in the firm's own documents rather than the model's general knowledge.

**Scoring models.** Multiple signals — growth velocity, team background, thesis alignment, relationship proximity — feed into composite scores that rank companies across the pipeline. These don't replace judgment; they change what gets seen first. An analyst reviewing 200 inbound companies in a week can't give each one equal attention. The scoring model surfaces the ones worth a second look.

**Investment thesis classification.** A trained classifier reads a company's profile and predicts which of the firm's investment themes it fits best. This helps with inbound filtering, surfaces overlooked companies already in the database, and gives the team a shared vocabulary for pattern-matching across the portfolio.

None of this replaced the structured data pipeline. It sits on top of it. Structured data gives the AI accurate grounding; the AI makes the structured data readable and actionable. You can't write a useful company summary if the underlying entity record is dirty. Every AI feature we added made me appreciate the years spent cleaning and normalizing data more, not less.

## What More Than a Decade Taught Me

The thing that surprised me most: data quality is a product problem, not just an engineering problem. The hardest bugs weren't in the code. They were in the data — a company that changed its name, a domain that got quietly acquired, a person who changed jobs three times in two years. The system needs opinions about identity, and those opinions need to be constantly questioned and updated. No amount of good code compensates for a dirty canonical record.

The boring infrastructure mattered more than I expected. Job deduplication, Redis locks, rate limiting, idempotent writes — none of it makes the changelog exciting. It's why the system runs reliably.

And working closely with an investment team for this long reshaped how I think about technology partnerships. The analysts don't think in data models. They think in relationships, in pattern recognition, in the feel of a founder conversation. Building something they'd actually reach for — rather than something technically correct but quietly ignored — meant staying close to the actual work, not just the requirements doc.

The technical complexity here is real. But the harder skill is knowing which complexity is worth building and which can wait. That judgment only comes from staying in the problem long enough to stop being surprised by it.
