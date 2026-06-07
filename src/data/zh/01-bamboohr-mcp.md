---
title: "开发 bamboohr-mcp：让 AI 直接对话 HR 系统"
date: 2026-06-01
tags: [AI, MCP]
excerpt: "我想让任何 LLM 都能直接调用 BambooHR 的 API。三天后，一个生产可用的 MCP 服务器诞生了。记录整个过程，以及那些出乎意料的收获。"
draft: false
---

每逢周五下午，HR 团队总会来找我。"能帮我拉一下各部门的人数吗？""下周谁请假了？""工程团队四月份共记录了多少工时？"

这些需求本身并不过分。数据都在 BambooHR 里，问题在于把它取出来的过程——登录系统、找到对应报表、设置日期筛选条件、导出 CSV，有时还要再做一番表格运算。不难，但繁琐。而且每次都绕回我这里，因为只有我熟悉整套操作。

我一直在关注 Model Context Protocol 生态的发展，Anthropic 发布这个协议规范以来，已经出现了不少有意思的项目。MCP 的理念很优雅：你写一个暴露"工具"的服务器，任何兼容 MCP 的客户端——Claude、Cursor、Windsurf 等等——都能自动发现并用自然语言调用这些工具。我当时就想：如果 HR 经理能直接问 Claude "本周谁在休假？"，Claude 自己去拿答案，那会怎样？

这就是 `bamboohr-mcp` 的由来。

## 先搞清楚要解决什么问题

动手写代码之前，我需要想清楚这个服务器到底应该做什么。BambooHR 的 API 有 80 多个端点——员工名册、考勤、薪酬福利、绩效考核、招聘流程、组织架构、自定义报表，应有尽有。我完全可以把所有端点都包进来。

但这是个陷阱。

问题不是"BambooHR 能做什么"，而是"我们的团队实际上会问什么"。我花了一个下午，把过去三个月 Slack 里所有 HR 相关的问题整理归类。结论很清晰：

- 谁今天请假了 / 谁在上班
- 项目和任务信息（填工时用）
- 员工名册查询
- 工时提交和审核
- 基本组织架构

这大约只覆盖了 20% 的 API 功能，却能满足 90% 的真实需求。我决定只做 12 个工具，不再往里添。

## 开发过程

我选择了 TypeScript，而不是 Python——BambooHR 的 API 是标准的 REST + JSON，Node 的 HTTP 生态配套非常完善。Anthropic 提供的 MCP SDK 让工具定义变得很直接。

每个工具的结构大致相同：

```typescript
{
  name: "fetch_employee_directory",
  description: "获取所有在职员工的姓名、邮箱、职位和部门",
  inputSchema: {
    type: "object",
    properties: {
      status: {
        type: "string",
        enum: ["Active", "Inactive"],
        description: "按就职状态筛选"
      }
    }
  }
}
```

具体实现就是对 BambooHR REST 接口做一层类型化的 fetch 封装，加上错误处理和响应归一化。架构层面最麻烦的是认证——BambooHR 用的是 API Key 认证，URL 里还需要带公司域名前缀。我通过环境变量来配置，这样不同的部署环境不需要改代码：

```typescript
const token = process.env.BAMBOOHR_TOKEN!;
const companyDomain = process.env.BAMBOOHR_COMPANY_DOMAIN!;
const employeeID = process.env.BAMBOOHR_EMPLOYEE_ID!;
```

最终发布的 12 个工具：

1. `fetch_employee_directory` — 员工基本信息列表
2. `fetch_whos_out` — 当前和即将到来的休假情况
3. `fetch_projects` — 考勤用的项目和任务列表
4. `fetch_time_entries` — 指定时段的工时记录
5. `submit_work_hours` — 提交项目工时
6. `get_me` — 当前用户信息
7. `fetch_timesheet` — 每日考勤视图
8. `fetch_departments` — 组织架构
9. `fetch_job_titles` — 职位列表
10. `fetch_benefits_summary` — 福利概览
11. `fetch_pto_balance` — 剩余假期余额
12. `fetch_holidays` — 公司法定节假日

## 第一版踩的坑

第一版没有处理分页。BambooHR 的员工列表是分页返回的，我只静默地返回了第一页。30 人的团队没问题，300 人的团队数据就会不完整，而且没有任何提示。后来写了一个通用的 `fetchAllPages` 工具方法，跟随 `Link` 响应头自动翻页，才解决这个问题。

我还低估了响应格式对 LLM 消费的重要性。BambooHR 原始 API 返回的是深层嵌套的对象，字段名也不太一致。LLM 能解析，但如果把数据规范化成扁平的、字段名清晰的对象，效果会好很多。最终为每个工具的响应单独写了一层轻量级的转换逻辑。

## 真正的惊喜

部署到内部环境三天后，HR 经理开始用了。不是通过开发人员——她用配置文件的方式把 Claude Desktop 直接连上了这个 MCP 服务器，开始直接提问。

她第一个真正的查询："上周哪些工程师没提交工时？"

Claude 用一个日期范围调用了 `fetch_time_entries`，又拉了员工名册，做了集合差运算，给出了一份名单。过去要花我十分钟的查询，她三十秒就搞定了。

这才是我真正理解 MCP 的瞬间。它不是一个 AI 功能，它是一个集成层——让你现有的系统对任何 LLM 都变得可访问，而不需要为每个使用场景单独搭建 UI。

## 如果重来一次

**限流。** BambooHR 有访问频率限制，一个提问方式不当的问题可能导致 Claude 快速连发大量工具调用。应该在服务器端加一个简单的令牌桶限流。

**更清晰的报错信息。** 认证失败时，目前的报错是 "401 Unauthorized"——调试 Claude 连接问题时毫无帮助。应该把 BambooHR 的原始错误响应内容透传出来。

**版本化策略。** 我完全没考虑 API 版本问题。一旦 BambooHR 废弃某个接口，服务器就会静默出错。应该加一个健康检查工具，验证所有接口都还能正常访问。

代码在 [github.com/encoreshao/bamboohr-mcp](https://github.com/encoreshao/bamboohr-mcp)，如果你想自己跑起来，或者想基于它对接其他 HRIS，这个模式很容易迁移——换掉 BambooHR 的部分，接上任何带 Token 认证的 REST API，一个下午就能搭出 MCP 服务器的基本骨架。
