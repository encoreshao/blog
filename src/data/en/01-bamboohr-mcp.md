---
title: "Building bamboohr-mcp: An MCP Server for HR APIs"
date: 2026-06-01
tags: [AI, MCP]
excerpt: "I wanted to let any LLM talk to BambooHR's API. Three days later I had a production MCP server in TypeScript. Here's exactly what I built and what surprised me along the way."
draft: false
---

Every Friday afternoon, someone on our HR team would ping me. "Can you pull the headcount by department?" "Who's out next week?" "How many hours did the engineering team log in April?"

They weren't being unreasonable. The data was all in BambooHR. It's just that getting it out required logging in, navigating to the right report, setting date filters, exporting a CSV, and sometimes doing a bit of spreadsheet math. Not hard — just tedious. And it kept falling on me because I knew where everything was.

I'd been watching the Model Context Protocol ecosystem grow since Anthropic released the spec. The premise is elegant: you write a server that exposes "tools", and any MCP-compatible client — Claude, Cursor, Windsurf, whatever — can discover and call those tools in natural language. I thought: what if the HR manager could just ask Claude "who's on leave this week?" and Claude would go fetch that answer itself?

That's what became `bamboohr-mcp`.

## Starting with the right question

Before writing any code, I had to decide what the server should actually do. BambooHR's API has over 80 endpoints — employee directory, time tracking, benefits, performance reviews, hiring pipelines, org charts, custom reports. I could try to wrap all of it.

That would have been a mistake.

The question isn't "what can BambooHR do?" It's "what does our team actually ask about?" I spent an afternoon going through the last three months of HR-related pings in Slack and categorized them. The answer was clear:

- Who's out / who's working today
- Project and task tracking (for timesheet purposes)
- Employee directory lookups
- Time entry submission and review
- Basic org structure

That's roughly 20% of the API surface, but it covered probably 90% of the real requests. I decided to ship 12 tools and not look back.

## The build

I chose TypeScript over Python because the BambooHR API is REST-based JSON and Node's HTTP ecosystem is excellent. The MCP SDK from Anthropic made the tool definition straightforward.

Each tool follows the same shape:

```typescript
{
  name: "fetch_employee_directory",
  description: "Get all active employees with name, email, job title, and department",
  inputSchema: {
    type: "object",
    properties: {
      status: {
        type: "string",
        enum: ["Active", "Inactive"],
        description: "Filter by employment status"
      }
    }
  }
}
```

The implementation side is just a typed fetch call wrapping BambooHR's REST endpoints, with error handling and response normalization. The hardest part architecturally was authentication — BambooHR uses API key auth with a company domain prefix in the URL. I wired this up via environment variables so the server can be configured per-deployment without touching code.

```typescript
const token = process.env.BAMBOOHR_TOKEN!;
const companyDomain = process.env.BAMBOOHR_COMPANY_DOMAIN!;
const employeeID = process.env.BAMBOOHR_EMPLOYEE_ID!;
```

The tools I ended up shipping:

1. `fetch_employee_directory` — all employees with basic info
2. `fetch_whos_out` — current and upcoming time-off
3. `fetch_projects` — project and task list for time tracking
4. `fetch_time_entries` — time logs for a given period
5. `submit_work_hours` — submit time entry for a project/task
6. `get_me` — current user's info from the token
7. `fetch_timesheet` — daily timesheet view
8. `fetch_departments` — org structure
9. `fetch_job_titles` — list of roles
10. `fetch_benefits_summary` — benefits overview
11. `fetch_pto_balance` — remaining leave balance
12. `fetch_holidays` — company holiday calendar

## What I got wrong the first time

My first version didn't handle pagination. BambooHR returns paginated results for employee lists, and I was silently returning only the first page. In a 30-person company that's fine. In a 300-person company, you'd get incomplete data with no warning. I fixed this by building a generic `fetchAllPages` helper that follows the `Link` headers.

I also underestimated how much the response format matters for LLM consumption. Raw BambooHR API responses have deeply nested objects with inconsistent field names. An LLM can parse them, but it works much better when you normalize the data into flat, clearly named objects. I ended up writing a lightweight transform layer for each tool's response.

## The surprise

Three days after deploying this internally, our HR manager started using it. Not via a developer — she connected Claude Desktop to the MCP server herself using the configuration file approach, and started asking questions directly.

Her first real query: "Which engineers haven't submitted their timesheets for last week?"

Claude called `fetch_time_entries` with a date range, fetched the employee directory, did a set difference, and replied with a list of names. The query that used to take me ten minutes took her thirty seconds.

That was the moment I understood what MCP actually is. It's not an AI feature. It's an integration layer that makes your existing systems legible to any LLM without building a custom UI for every use case.

## What I'd do differently

**Rate limiting.** BambooHR's API has rate limits, and a poorly-phrased question can cause Claude to make a lot of tool calls in quick succession. I'd add a simple token bucket on the server side.

**Better error messages.** When authentication fails, the current error is "401 Unauthorized" — not helpful when you're debugging why Claude can't connect. I'd surface the actual BambooHR error response.

**Versioning strategy.** I haven't thought about API versioning at all. When BambooHR deprecates an endpoint, the server will silently break. I'd add a health-check tool that validates all endpoints are reachable.

The repo is at [github.com/encoreshao/bamboohr-mcp](https://github.com/encoreshao/bamboohr-mcp) if you want to run it yourself or adapt it for a different HRIS. The pattern generalizes easily — swap BambooHR for any REST API with an auth token and you have the skeleton of an MCP server in an afternoon.
