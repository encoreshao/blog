---
title: "WorkflowPro: Building Office Automation That Actually Gets Used"
date: 2025-07-20
tags: [Rails, Product]
excerpt: "How I built an approval workflow system for an elevator manufacturer that ran three years without downtime — and what I learned about getting enterprise software right the first time."
draft: false
---

Enterprise software has a reputation for being bloated, difficult, and expensive. I've seen why that reputation exists — most of it is built by teams optimizing for contract scope rather than for the people who will actually use it every day.

WorkflowPro was a chance to do it differently.

## The problem

The client was an elevator manufacturing company with 200+ employees across operations, HR, finance, and project management. Their approval processes — purchase requests, expense reimbursements, time-off requests, equipment procurement, contract reviews — ran entirely on email and printed forms. Things got lost. Approvals took weeks for decisions that should take hours. No one had visibility into where a request was in the process.

HR specifically was in pain: they were managing employee documentation, onboarding checklists, policy sign-offs, and department transfers through a combination of shared folders and manual follow-ups. It was held together by institutional knowledge that lived in the heads of two specific people.

They'd tried an off-the-shelf workflow product. It was too generic, too expensive, and required a consultant every time they needed to add a new form. After two years of fighting it, they came to us.

## The architecture

WorkflowPro is a Rails monolith. I chose monolith deliberately — 200 users across one company does not need microservices, and the operational simplicity of a single deployment paid off many times over the years it was in production.

The core data model is built around three concepts:

**Workflow templates** define the steps, approvers, and conditions for a process. A purchase request template might say: any amount under 5,000 RMB needs one manager approval; over 5,000 needs manager plus finance director; over 50,000 needs those two plus a VP sign-off.

**Workflow instances** are individual requests moving through a template. When an employee submits a purchase request, an instance is created. The system knows which step it's on, who needs to act, and what happens next.

**Actions** are the events that advance instances: approvals, rejections, requests for clarification, automatic time-based escalations.

This separation turned out to be the most important design decision I made. Workflow templates change occasionally; instances never change their template mid-flight. Keeping them separate meant we could update approval chains without affecting in-progress requests, which is exactly the behavior you need.

## Getting the data model right

In the design meeting, I spent two hours pushing back on how the client wanted to model their HR data. They wanted to track employees as rows in a single table with dozens of columns. I wanted to model the relationships explicitly: employees have positions, positions belong to departments, departments have heads.

It was the right fight to have. The HR integration — pulling employee data to auto-populate requestor information, auto-route to the correct manager, and handle org-chart changes — only worked cleanly because the relational model reflected reality.

Three years later, the schema has had zero breaking changes. New feature requests fit naturally into the existing structure: document versioning, delegation of approval authority, bulk processing, department transfer workflows. They all composed with what was already there.

## The features that mattered

I built a lot of things. The features that actually mattered turned out to be a short list.

**Email notifications that include the action button.** Approvers don't go to the app — they're in email. Every notification email contains an "Approve" or "Reject" button that authenticates with a one-time token and records the action without requiring the approver to log in. Adoption went from 40% to 90% when we added this.

**Delegation.** People take vacations. The ability to delegate your approval authority to a colleague for a date range, with automatic reversion, solved a problem the previous system couldn't handle at all. It turned out to be one of the most-mentioned features in feedback.

**A proper audit trail.** Every state change is logged with who did it, when, and any comment they left. Operations teams in manufacturing care deeply about records — they need to be able to reconstruct a decision for compliance purposes. The audit log was a checkbox in the original spec; it became a frequently-used feature.

**Escalation timers.** If an approval sits unacted on for X hours, it automatically escalates to the approver's manager. This single feature, which took two days to build, reduced the "stuck in someone's queue" problem to near zero.

## What I got wrong

The document management feature was over-engineered. I built a versioned document storage system with check-in/check-out, preview rendering, and a permission matrix that could express fine-grained access controls. Maybe 20% of that was ever used. A simple file attachment with version history would have served 90% of the use cases.

I also built a reporting dashboard with 15 different charts. Users looked at two of them: "requests pending my approval" and "how long do approvals take on average by department." I should have shipped those two and seen whether anyone asked for more before building the rest.

## Three years without downtime

The thing I'm most proud of isn't a specific feature. It's that the system ran for three years in production, serving 200+ daily active users, without a single unplanned outage.

That reliability came from boring decisions: a single Heroku standard dyno with Puma, Postgres as the only data store, Sidekiq for background jobs with Redis, comprehensive test coverage on the state machine transitions, and a staging environment that matched production exactly.

The one time we had a problem was a database migration that locked a table for longer than expected during business hours. We had a post-mortem. We added zero-downtime migration practices to our deployment checklist. It never happened again.

Enterprise software doesn't need to be complicated. It needs to be reliable, understandable, and designed around how people actually work. WorkflowPro was all three, and that's why it's still running.
