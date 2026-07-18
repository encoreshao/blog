---
title: "Building a Ruby Wrapper for the Crunchbase API"
date: 2024-08-18
tags: [Ruby, "Open Source", API]
excerpt: "What I learned wrapping a third-party API in idiomatic Ruby — rate limits, authentication flows, model design, and the V3 to V4 migration I didn't see coming."
draft: false
---

The Crunchbase API is genuinely useful. It has company profiles, funding round data, acquisition history, leadership teams, and IPO records for most companies you'd care about. When you're building due diligence tooling, market research features, or anything that needs startup data at scale, it's one of the few data sources that actually covers the space.

But the raw API isn't pleasant to use. You get flat JSON responses for entities that have complex relationships. You need to know the right permlink format. Pagination has its own conventions. And the authentication model — API key per request, rate limits enforced server-side with little feedback — requires defensive coding that your app shouldn't have to think about.

I built `crunchbase-ruby-library` to put a clean Ruby interface on top of all of that.

## What the gem does

The gem wraps Crunchbase API v3.1. At its core, it provides:

- A client object that handles authentication, timeout configuration, and request lifecycle
- Model classes for each entity type: Organization, Person, Product, IPO, Acquisition, FundingRound
- A search interface that translates Ruby hash arguments into the API's query parameter format
- A relationship-aware `get` method that can fetch an entity with any of its related data in a single call

```ruby
client = Crunchbase::Client.new

# Search for organizations
results = client.search({ name: "Stripe" }, 'organizations')
results.total_items   # => 12
results.results       # => [#<Crunchbase::Model::Organization ...>, ...]

# Fetch a single entity with relationships
org = client.get('stripe', 'Organization')
org.headquarters      # => location object
org.funding_rounds    # => array of FundingRound objects
```

The configuration is minimal by design:

```ruby
Crunchbase::API.key     = ENV['CRUNCHBASE_API_KEY']
Crunchbase::API.timeout = 60
Crunchbase::API.debug   = false
```

One line to wire it up, and every call in your app just works.

## The design problems

Wrapping an external API in Ruby objects sounds straightforward until you hit the specifics.

**Relationships are inconsistent.** Crunchbase's entity model has dozens of relationship types, and they're not consistently structured. Some relationships return arrays; some return single objects. Some include summary data inline; some require separate requests. I spent more time reading API documentation and writing tests against the real API than I did writing model code. The relationship list for Organization alone is 20+ entries:

```
primary_image, founders, current_team, investors, owned_by,
sub_organizations, headquarters, offices, products, categories,
customers, competitors, funding_rounds, acquisitions, ipo...
```

Each one needed its own handling. The approach I settled on was using `method_missing` to delegate unknown method calls to a relationships hash, populated lazily from the API response. This kept the model classes clean while still allowing natural Ruby access patterns:

```ruby
org.founders          # fetches if not loaded, returns PersonSummary objects
org.funding_rounds    # fetches if not loaded, returns FundingRound objects
```

**The batch search API is different.** Crunchbase added a batch endpoint that accepts up to 10 requests and returns a mixed array of results. Building a clean Ruby interface for this was tricky — you pass in heterogeneous request types and get back heterogeneous results, including error objects for invalid UUIDs. I ended up creating a `BatchSearch` model that wraps the results array and lets you iterate over successes and filter out errors:

```ruby
requests = [
  { type: 'Organization', uuid: org_uuid, relationships: ['founders'] },
  { type: 'Person', uuid: person_uuid, relationships: [] }
]

batch = client.batch_search(requests)
batch.results.each do |result|
  next if result.is_a?(Crunchbase::Model::Error)
  puts result.name
end
```

**Rate limiting.** V3.1 enforces rate limits but doesn't tell you clearly when you're approaching them. You get a 429 response when you hit the ceiling. The gem wraps all requests with retry logic and exponential backoff, but it took a few production incidents to get the backoff timing right.

## The V3 to V4 migration

About a year after publishing the gem, Crunchbase announced they were deprecating V3.1 in favor of V4 — a substantially different API with a new authentication model, different entity schemas, and a completely redesigned search interface.

I made a decision I'm still not entirely sure about: I kept `crunchbase-ruby-library` as a V3.1 wrapper and built a separate gem — `crunchbase4` — for V4 rather than upgrading in place.

The reason: V4 is different enough that a migration would break almost every method signature and model attribute. Any app using the V3 gem would need significant rework, and doing that under a patch version bump felt dishonest. A new gem gave V4 users a clean start and let existing V3 users stay on a stable dependency while they planned their migration.

In practice, this meant maintaining two gems, which was more work than I'd hoped. But it gave downstream users predictability, and predictability is the most underrated thing a library author can provide.

## What I'd do differently

**More aggressive error types.** The gem raises a single `Crunchbase::Error` class for API failures. A year of production use taught me that callers need to distinguish between "API key invalid" (fatal, alert immediately), "rate limited" (retry), "entity not found" (expected, handle gracefully), and "API down" (circuit-break). A single error class pushes that differentiation onto every caller. A hierarchy of error classes would have been better from day one.

**Test against recorded fixtures earlier.** I used `VCR` for recording HTTP interactions, but I added it late. The first tests hit the real API, which was slow, required credentials in CI, and occasionally broke when Crunchbase changed response formats. Recording all API interactions from the start would have made the test suite faster and more reliable.

**Version the models explicitly.** Crunchbase changed the shape of several response objects between minor API versions without a major version bump. The gem's models assumed a stable shape and broke silently when fields were added or renamed. Explicit schema versioning, or at minimum defensive attribute access with `dig`, would have caught these breaks sooner.

The gem is at [github.com/encoreshao/crunchbase-ruby-library](https://github.com/encoreshao/crunchbase-ruby-library) and still works for V3.1 API access. If you're building against V4, the `crunchbase4` gem at [github.com/ekohe/crunchbase4](https://github.com/ekohe/crunchbase4) is where that work continues.
