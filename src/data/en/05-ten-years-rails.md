---
title: "10 Years of Rails: What I Still Reach For Every Day"
date: 2025-12-10
tags: [Ruby, Rails]
excerpt: "Not a framework review. A personal account of which Rails patterns aged well, which didn't, and what I've built that I'm still proud of."
draft: false
---

My first Rails app was a disaster. I was 23, I'd just learned the framework from Michael Hartl's tutorial, and I built a social platform for musicians with the confidence of someone who didn't know what they didn't know. The app had N+1 queries on every page. The authentication was homebrew. The deployment was a single Heroku dyno that restarted on every request above 512MB memory.

It worked, sort of, for a few months. Then it collapsed under its own weight and I learned what "performance" meant by having to fix it in production.

That was ten years ago. I've been writing Rails professionally since then — at startups, at Ekohe, for enterprise clients across retail, logistics, HR, and construction. Here's what actually held up and what I've quietly stopped doing.

## What aged well

**Migrations.** I've used database migration tools in a dozen frameworks across my career. Rails migrations are still the best I've encountered. The convention of one change per file, the separation of `up` and `down` (or the `change` shorthand), the timestamps as sequential identifiers — it all just works, and it works reliably at every scale I've shipped at. When I see migration tools in other ecosystems, I'm always comparing them to this.

**ActiveRecord callbacks.** Controversial, I know. The community went through a phase of arguing that callbacks are evil and everything should be service objects with explicit orchestration. I tried that for a year. I missed `after_commit`. For lifecycle events that genuinely belong to a model — auditing, cache invalidation, notification triggers — callbacks are exactly the right place. The problem isn't callbacks; it's using them for business logic that belongs somewhere else.

**Convention over configuration.** The `rails new` command gives you a working app. The file structure tells you where to put things. New developers to a Rails codebase can find their way around in hours, not days. After spending months in frameworks where configuration is a discipline unto itself, I keep coming back to how productive this convention makes teams.

**The asset pipeline (and now Propshaft/Importmap).** The web frontend world changes fast. Rails has had to adapt — asset pipeline to Webpacker to the current Importmap + Propshaft default. The adaptations have been bumpy, but the underlying idea of treating frontend assets as first-class citizens of the app has aged better than "bolt a separate frontend app onto your API."

## What I stopped doing

**Service objects everywhere.** This was a specific era of Rails discourse — roughly 2015 to 2020 — where the advice was to extract all business logic into Plain Old Ruby Objects called service objects. `UserRegistrationService`, `OrderFulfillmentService`, `ReportGeneratorService`.

Some of these are appropriate. Most of them just moved complexity from one file to another without making it simpler. I'd look at a controller action that called five service objects and realize it was harder to understand than the equivalent code in a fat model would have been. Now I reach for service objects when the alternative would create a model that does too many different things — not as a default pattern for everything.

**Decorators over partials.** There's a legitimate use case for the decorator pattern in Rails — Draper was popular for a while. But the overhead of wrapping every object to add presentation logic was rarely worth it for the apps I was building. `helper_method` in controllers and well-organized partials cover most cases without the indirection.

**Custom authentication before trying Devise.** I rolled my own authentication for the first two years because I wanted to understand the primitives. That was a valuable exercise once. Now I use Devise or the newer `authentication-zero` generator unless there's a specific reason not to. The primitives haven't changed. My time has more valuable uses.

## Projects I'm still proud of

**WorkflowPro**: An office automation system with approval workflows, HR integration, and document management for an elevator manufacturing company. It was a Rails monolith serving 200+ employees with zero downtime for three years. The thing I'm proud of isn't the features — it's the data model. We got the domain model right in the first design meeting, and it didn't require major revision as the requirements grew.

**The elevator industry ERP**: Multi-tenant Rails with project management, contract tracking, and financial reporting. I built it in 2019 and it's still in production. The codebase is older than some of the engineers who maintain it now. The fact that it's maintainable — that a new developer can understand it in a week — is the outcome I'm most satisfied with.

**An internal search platform at Ekohe**: Elasticsearch integration with a Rails API, doing faceted search over a few million documents. Not glamorous, but it was technically satisfying to get right. The indexing pipeline and the query builder are still among the most carefully designed code I've written.

## What I still use Rails for

Complex data-backed applications with multiple user roles, approval workflows, audit trails, and integrations with external systems. E-commerce backends. API backends for mobile apps. Admin interfaces for operations teams.

I don't use Rails for: real-time collaborative apps (Phoenix/Elixir is better here), pure serverless functions, or frontend-heavy SPAs where the server is just a data API and you want something lighter than Rails.

The framework is 20 years old and still my first choice for a broad class of problems. That's not nostalgia — it's just the right tool.
</content>
