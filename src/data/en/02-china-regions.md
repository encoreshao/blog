---
title: "china_regions: Lessons from a Ruby Gem"
date: 2026-05-10
tags: [Ruby, "Open Source"]
excerpt: "What I learned shipping a Ruby library for Chinese administrative regions — and why documentation matters more than the code itself."
draft: false
---

The problem started with a form. We were building a registration flow for a Rails app, and we needed a cascading dropdown for Chinese provinces, cities, and districts. It sounds trivial. It is not.

China has 34 province-level divisions, 333 prefecture-level cities, and over 2,800 county-level divisions. The data changes — administrative regions are periodically reorganized by the State Statistics Bureau. Every app that needed this had to solve it from scratch: find a data source, clean it, load it into a database, build the associations, write the UI hooks. I watched three different teams at three different companies do this badly.

So I built `china_regions`.

## What the gem actually does

At its core, `china_regions` is a Rails engine that provides three database-backed models — `Province`, `City`, and `District` — pre-loaded with official data from the Ministry of Civil Affairs. You add it to your Gemfile, run the generator, run the migration, and your app has a complete, queryable hierarchy of Chinese administrative divisions.

```ruby
Province.all           # 34 provinces/municipalities/regions
City.where(province: Province.find_by(name: "广东省"))  # Guangdong's cities
District.all.count     # 2800+
```

The generator also copies locale files for Chinese and English names, so the same region object can render as "广东省" or "Guangdong Province" based on your `I18n.locale`.

For UI, there's a JavaScript helper that drives cascading selects — you pick a province, the city dropdown populates, you pick a city, the district dropdown populates. It works with standard Rails form helpers.

## The data problem

Getting the data right was harder than the code. The official source is the National Bureau of Statistics website, but it publishes data as nested HTML tables, not an API. I wrote a scraper, validated it against the Ministry of Civil Affairs list, and cross-referenced with a second source to catch discrepancies.

The data has quirks. Some municipalities (Beijing, Shanghai, Tianjin, Chongqing) are both province-level and contain "districts" that function like cities. The 2-level vs 3-level hierarchy isn't consistent across all regions. I made judgment calls that probably aren't perfect, but they cover 95% of real use cases.

The last update I shipped brings the dataset to the 2018 revision — the most recent official publication at the time. Keeping it current is the biggest maintenance burden; the NBS updates the data periodically and I have to re-run the scraper, validate the diff, and publish a new gem version.

## Why it got 25 stars

I want to be honest about this: the code is not special. It's a standard Rails engine with modest complexity. The reason people starred it is that the problem is common and the alternatives are worse.

When I shipped the gem, the solutions I could find online were either abandoned (outdated data, broken generators), manual (CSV files you had to load yourself), or API-dependent (requiring network calls for region lookups). `china_regions` solved all three problems: maintained data, zero config, local queries.

The lesson I took from this is that **solving a boring, real problem well beats solving an interesting problem beautifully**. Cascading region dropdowns for Chinese apps is not exciting. But every Rails developer building a Chinese-market app runs into it. That's a large enough audience to make a gem worthwhile.

## Documentation as the real product

Here's what I got wrong in v0.1: the README was three bullet points and a code snippet. I assumed developers would figure it out from the source.

They didn't. Issues started coming in: "How do I customize the models?" "The migration failed on PostgreSQL with a column name conflict." "How do I add my own regions?" "What locale keys does this use?"

Every one of those questions was answerable in under five minutes if you read the source. But people don't read the source. They read the README, and if the README doesn't answer their question, they open an issue.

I rewrote the documentation from scratch — installation, configuration, model usage, form helper examples, troubleshooting for common errors, how to update the data. The issue volume dropped by half.

Documentation is the interface between your code and the people who use it. You can have a perfect implementation and zero adoption if the interface is confusing. The README is not an afterthought. For a library, it's the most important thing you ship.

## What I'd change

**Smarter data updates.** I'd design a proper update mechanism — a rake task that checks the NBS website for changes and diffs the existing data — rather than the current manual scrape-and-replace approach.

**Separate the data from the engine.** The gem bundles data and functionality together. If someone needs to customize the region hierarchy for a specific use case, they're fighting the gem rather than using it. A cleaner design would separate the data (as a data gem) from the Rails integration layer.

**Test across more Rails versions from the start.** I've had to do painful retroactive compatibility work as Rails evolved. CI from day one across a matrix of Ruby and Rails versions would have caught these earlier.

The gem is at [github.com/encoreshao/china_regions](https://github.com/encoreshao/china_regions). If you're building for the Chinese market with Rails, it'll save you a week of work.
