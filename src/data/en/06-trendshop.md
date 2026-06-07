---
title: "Building TrendShop: When AI Meets Fashion Discovery"
date: 2025-10-05
tags: [AI, Product]
excerpt: "How we built a social fashion platform powered by AI recommendation — what worked, what the users actually wanted, and the pivot we almost didn't make."
draft: false
---

The pitch for TrendShop was clean: a social platform where AI surfaces fashion you'll actually buy, based on what you and people like you are engaging with. Think Pinterest's discovery model plus a recommendation engine that learns faster because it has social signals, not just individual behavior.

We believed in the idea. We built it. And then we learned the difference between what people say they want and what they do.

## The original architecture

The technical foundation was a social data collection pipeline feeding an AI recommendation engine. Users followed each other, saved items, shared outfits. The AI analyzed those signals — engagement patterns, save rates, category affinities, price range behavior — and generated a personalized feed.

The backend was Rails, naturally. The recommendation engine started as a collaborative filtering model (similar users bought similar things) and grew to incorporate content-based signals as we accumulated more data. The social graph lived in a relational database; the recommendation models ran separately and wrote recommendations back to a cache the Rails app could query.

We built integrations with several fashion retailers' product catalogs via their affiliate APIs. This gave us a real inventory to recommend from, with current pricing and availability.

The tech worked well. The app felt good to use. And almost none of our users engaged with it the way we'd designed.

## What they actually did

We expected TrendShop to be used like Instagram — daily check-ins, browsing the feed, saving things to wishlist for later. What we found in the analytics:

Users arrived with a specific intent. "I need an outfit for a wedding." "I'm looking for work-appropriate summer clothes." "My friend has a style I want to match." They'd use the AI discovery feature heavily for 20-30 minutes, find what they wanted, and then not come back until they had another need. 

The social features — following, sharing, building a profile — had almost no organic adoption. We'd built a social network nobody asked for. The behavior we were seeing was closer to a search engine with strong recommendations than a social platform.

## The pivot we almost didn't make

There's a specific kind of organizational denial that happens when your assumptions turn out to be wrong. The social features were the most technically interesting parts of the product. They were what made us different from a generic fashion search. Abandoning them felt like admitting failure.

We spent two months trying to increase social engagement with features we believed would unlock the behavior we wanted. Nothing moved.

The honest reckoning: we had built product assumptions into the architecture and we were reluctant to revise them because the architecture was hard to change. The social graph was woven through the data model. Pivoting to a pure discovery and recommendation model would mean significant rework.

We did it anyway. We stripped the social layer to a minimal "follow for recommendations" feature (so the collaborative filtering signals still flowed) and rebuilt the UX around intent-based sessions: tell us what you're looking for, and we'll surface the best options across our catalog.

Session time dropped. Transaction conversion increased by 40%.

## What the AI actually got right

The recommendation engine ended up being most useful not in the feed but in a specific interaction: showing users items that matched the style of something they already liked but hadn't found.

We called this "similar style, different price point." A user saves a designer bag. The engine surfaces three alternatives at 30%, 50%, and 70% of the price, all with similar visual characteristics and category signals. For users on a budget, this was genuinely valuable — they'd come in knowing what they wanted stylistically and leave with something they could actually buy.

This was the AI doing something a search engine can't: understanding style as a multidimensional space and finding neighbors, not just keyword matches.

## Lessons for AI product builders

**The AI feature should solve a problem the user already has, not create a new use pattern.** Our social discovery assumption required users to adopt a new behavior (casual browsing for fashion inspiration). The "similar style" feature solved a problem users brought to us (I know what I want, help me find the affordable version).

**Measure the behavior you're changing, not the behavior you're adding.** We measured daily active users and session length, both of which optimized against casual browsing. We should have measured "did the user find something they wanted and buy it?" much earlier.

**Data model debt is real.** We paid a significant rework cost for the pivot because the social assumptions were deep in the schema. If you're uncertain about a core product assumption, build that part of the system with the least coupling possible.

TrendShop taught me that AI works best when it augments a user's existing intent rather than trying to create new behavior. That's a design principle I've applied to every AI product since.
