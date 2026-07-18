---
title: "ruby-office365: A Ruby Client for Microsoft Graph"
date: 2026-07-17
tags: [Ruby, "Open Source", API]
excerpt: "Why I built a small Ruby gem for Office 365 instead of using what already existed, and what it actually looks like to pull mail, calendars, and contacts through it."
draft: false
---

A client asked for something that sounded almost trivial: show their customers' upcoming Outlook meetings inside our product's dashboard. Read their calendar, render it next to the rest of their day. Two-day estimate, I figured, mostly integration glue.

Then I went looking for a Ruby gem to talk to Microsoft Graph and found a graveyard. The `o365` gem hadn't been touched in years and threw deprecation warnings on install. `microsoft_graph` was auto-generated from Microsoft's OpenAPI spec — technically complete, but every call meant fighting a client object that mirrored the entire Graph API surface instead of the six endpoints I actually needed. Nothing in between existed. So I wrote `ruby-office365` instead of the calendar feature, and the calendar feature came a week later.

## What it needs to do

Microsoft Graph itself isn't hard, it's just wide. One host, one auth scheme, and then dozens of resource paths that all shape their JSON slightly differently — mailboxes nest differently than calendars, events carry `@odata.nextLink` for pagination but subscriptions don't, and every response wraps its payload in an OData envelope you have to peel off before you get to anything useful.

I wanted the gem to hide all of that behind three things: a client you configure once, model objects instead of raw hashes, and pagination that just worked without the caller thinking about it.

```ruby
client = Office365::REST::Client.new do |config|
  config.access_token = "YOUR_ACCESS_TOKEN"
  config.debug = false
end
```

Every resource — mailbox, calendars, contacts, events — funnels through one shared method that turns Microsoft's raw response into `{ results: [...], next_link: "..." }`. Fetch a single record by id and you still get a results array with one model in it. Same shape everywhere, whether you're on page one or page six. That consistency is the entire reason the gem exists instead of just hitting the API directly with Faraday.

## What it actually looks like to use

Get your own profile:

```ruby
response = client.me
response.display_name   # => "Hello World"
response.as_json        # => { display_name: "Hello World", mail: nil, ... }
```

Pull calendars and events:

```ruby
client.calendars[:results]
client.events[:results]
client.events[:next_link]

# a specific window
client.events({
  startdatetime: "2024-11-14T00:00:00.000Z",
  enddatetime: "2024-11-21T00:00:00.000Z"
})

# a single event by id — still comes back as a one-item array
client.event("identifier")[:results]
```

Contacts and mail work the same way:

```ruby
client.contacts[:results][0].display_name
client.messages({ filter: "createdDateTime lt 2022-01-01" })
```

And refreshing an expired token doesn't require a separate library:

```ruby
client = Office365::REST::Client.new do |config|
  config.tenant_id = tenant_id
  config.client_id = client_id
  config.client_secret = client_secret
  config.refresh_token = refresh_token
end

response = client.refresh_token!
response.access_token
```

Later on, when we needed to react to changes instead of polling for them, the gem grew webhook subscriptions too — `client.create_subscription(args)` registers a callback URL with Graph, and `client.renew_subscription(args)` keeps it alive before it expires. Same client, same call shape, one more resource.

## Why it's built this way

The design choice that mattered most was routing every single resource through that one `wrap_results` method rather than letting each endpoint parse its own response. Graph's pagination convention — check for `@odata.nextLink`, use it verbatim as the next request URL if present, otherwise build the URL from query params — only had to be written once, in one place, instead of once per resource with the fifth copy inevitably drifting from the first four.

## Problems found and fixed

**A dependency on Rails that nothing declared.** The first version built its query strings with `to_query`, a method that only exists because ActiveSupport monkey-patches it onto `Hash`. That's fine inside a Rails app and breaks immediately in a plain Ruby script or a non-Rails service, with an error that just says the method doesn't exist and gives no hint why. The fix was to stop borrowing it — write a small `Hash#ms_hash_to_query` using nothing but `CGI.escape` from the standard library, and drop the implicit dependency entirely. A gem meant to be usable outside of Rails shouldn't quietly require it.

**A pagination bug that never threw an error.** The date-range branch of the `events` method — the one that calls Graph's `calendarView` endpoint instead of the plain events endpoint — was written as a near-copy of the plain branch, and it built its own argument hash from scratch instead of merging in whatever the caller had passed. That meant a `next_link` a caller was using to page through results got silently dropped before it ever reached the URL builder. A background job paginating a calendar view would keep re-issuing the same first-page request instead of advancing — no crash, no exception, just the same page of events coming back until the access token expired and the job failed for an unrelated reason. The fix was one line, merging the caller's args instead of building a fresh hash, but it only shipped broken because that branch had skipped the pattern the rest of the gem followed.

## When I'd actually reach for it

`ruby-office365` isn't trying to cover the whole Graph API the way `microsoft_graph` does, and I don't think it should. It covers mail, calendars, contacts, events, and subscriptions, because those are the things a product actually asks for when someone says "sync our users' Outlook data." If you need Teams, SharePoint, or OneDrive through Graph, the generated client is the right tool — you want completeness there, not a hand-rolled wrapper guessing at endpoints it's never called.

But for the common case — a background job or a dashboard that needs someone's mail, calendar, or contacts and doesn't want to hand-build OData query strings to get them — a client you configure in three lines and call like a normal Ruby object is worth more than API coverage you'll never use.

`ruby-office365` is at [rubygems.org/gems/ruby-office365](https://rubygems.org/gems/ruby-office365).
