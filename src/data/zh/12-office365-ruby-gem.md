---
title: "ruby-office365：一个 Microsoft Graph 的 Ruby 客户端"
date: 2024-12-11
tags: [Ruby, 开源, API]
excerpt: "为什么我没用现成方案，而是自己写了个 Office 365 的 Ruby Gem——以及用它拉邮件、日历、联系人到底是什么样子。"
draft: false
---

客户的需求听起来非常简单：把他们客户的 Outlook 日程显示在我们产品的 Dashboard 里，读一下日历，渲染在当天视图旁边就行。我当时估了两天，觉得基本就是接口对接的活儿。

结果去找一个能对接 Microsoft Graph 的 Ruby Gem 时，发现全是坟场。`o365` 这个 Gem 好几年没更新了，装的时候一堆废弃警告；`microsoft_graph` 是从微软的 OpenAPI 规范自动生成的，功能是全，但每次调用都要跟一个映射了整个 Graph API 的客户端对象较劲，而我实际只需要六个接口。中间地带的选项一个都没有。于是我没有先做日历功能，而是先写了 `ruby-office365`，日历功能是一周之后才补上的。

## 它需要做到什么

Microsoft Graph 本身不难，难在"宽"。一个 Host、一套认证方式，然后是几十个资源路径，每个返回的 JSON 结构都有细微差别——mailbox 和 calendar 的嵌套方式不一样，event 用 `@odata.nextLink` 做分页但 subscription 不用，而且每个响应都套了一层 OData 信封，得先剥掉才能拿到有用的数据。

我希望这个 Gem 把这些细节都藏起来，只留下三件事：一次性配置好的客户端、模型对象而不是裸 Hash，以及调用方完全不用操心的分页。

```ruby
client = Office365::REST::Client.new do |config|
  config.access_token = "YOUR_ACCESS_TOKEN"
  config.debug = false
end
```

`mailbox`、`calendars`、`contacts`、`events` 这几个资源都走同一个方法，把 Graph 返回的原始响应转成 `{ results: [...], next_link: "..." }`。哪怕是按 id 取单条记录，返回的也是一个只装一个模型的数组，形状始终一致，不管你拿到的是第一页还是第六页。这种一致性，就是自己写这个 Gem 而不是直接用 Faraday 调 API 的全部理由。

## 实际用起来是什么样

拿自己的资料：

```ruby
response = client.me
response.display_name   # => "Hello World"
response.as_json        # => { display_name: "Hello World", mail: nil, ... }
```

拉日历和日程：

```ruby
client.calendars[:results]
client.events[:results]
client.events[:next_link]

# 按时间范围取
client.events({
  startdatetime: "2024-11-14T00:00:00.000Z",
  enddatetime: "2024-11-21T00:00:00.000Z"
})

# 按 id 取单条 event，返回的依然是一个数组
client.event("identifier")[:results]
```

联系人和邮件也是一样的用法：

```ruby
client.contacts[:results][0].display_name
client.messages({ filter: "createdDateTime lt 2022-01-01" })
```

刷新过期的 token 也不需要额外的库：

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

后来我们需要对变更做出反应而不是一直轮询，Gem 就多了 webhook subscription 这块——`client.create_subscription(args)` 向 Graph 注册一个回调地址，`client.renew_subscription(args)` 在它过期前续期。还是同一个客户端，调用方式一样，只是多了一种资源。

## 为什么这么设计

最关键的设计决定是让所有资源都走同一个方法，而不是让每个接口自己解析响应。Graph 的分页规则——先看有没有 `@odata.nextLink`，有就原样当下一次请求的 URL，没有就自己拼查询参数——只需要写这一处，而不是每个资源写一遍，然后第五份拷贝不可避免地跟前四份长歪。

## 踩过的坑和怎么修的

**一个没人声明过的 Rails 依赖。** 最早的版本用 `to_query` 拼查询字符串，而这个方法之所以能用，纯粹是因为 ActiveSupport 给 `Hash` 打了猴子补丁。在 Rails 应用里没问题，但放到一个普通 Ruby 脚本或者非 Rails 服务里立刻就炸，报错只会说这个方法不存在，完全看不出原因。修法是不再蹭这个便车——自己写一个 `Hash#ms_hash_to_query`，只用标准库里的 `CGI.escape`，把这个隐性依赖彻底去掉。一个号称能脱离 Rails 使用的 Gem，不应该悄悄地离不开它。

**一个从不报错的分页 Bug。** `events` 方法里按日期范围取的那个分支——调用 Graph 的 `calendarView` 接口而不是普通 events 接口的那个——是照抄普通分支写的，自己从头拼了一份参数 Hash，而不是把调用方传进来的参数合并进去。结果就是，调用方为了翻页传进来的 `next_link`，还没到拼 URL 那一步就被悄悄丢掉了。一个正在翻页的后台任务会不断重复发出同一个第一页请求，而不是往前翻——不报错，不崩溃，就是同一页 event 一直返回，直到 access token 过期，任务因为一个看似无关的原因失败了才被注意到。修复只改了一行，把调用方的参数合并进去而不是重新拼一个 Hash，但这个分支一开始就写坏了，正是因为它跳过了 Gem 其他地方都在遵循的写法。

## 什么时候真的该用它

`ruby-office365` 没打算覆盖整个 Graph API，我也不觉得它应该。它覆盖了邮件、日历、联系人、事件和订阅通知，因为这些正是产品说"帮我同步一下用户的 Outlook 数据"时真正会用到的东西。如果你需要通过 Graph 对接 Teams、SharePoint 或者 OneDrive，自动生成的客户端才是对的工具——那种场景你要的是覆盖面，不是一个手写的、猜接口猜出来的封装。

但对于更常见的情况——一个后台任务或者 Dashboard 需要拿某个用户的邮件、日历或联系人，又不想为此手写 OData 查询字符串——一个三行配置好、像普通 Ruby 对象一样调用的客户端，比你用不上的 API 覆盖面更值钱。

`ruby-office365` 在 [rubygems.org/gems/ruby-office365](https://rubygems.org/gems/ruby-office365)。
