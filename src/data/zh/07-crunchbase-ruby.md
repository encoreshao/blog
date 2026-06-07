---
title: "为 Crunchbase API 开发一个 Ruby 封装库"
date: 2025-09-15
tags: [Ruby, 开源, API]
excerpt: "把一个第三方 API 包装成惯用 Ruby 的过程中，我学到了什么——限流、认证流程、模型设计，以及那次我没预料到的 V3 到 V4 迁移。"
draft: false
---

Crunchbase API 真的很有用。它有公司档案、融资轮次数据、并购历史、管理团队信息和 IPO 记录，基本覆盖你会关心的大多数公司。如果你在构建尽职调查工具、市场研究功能，或者任何需要规模化获取创业数据的东西，它是为数不多能真正覆盖这个领域的数据源。

但原始 API 用起来不舒服。你会得到代表复杂关系的扁平 JSON 响应，需要知道正确的 permalink 格式，分页有自己的一套规则，认证模型——每个请求都要带 API Key，服务端强制执行限流且反馈很少——需要大量防御性编码，但这些不应该让你的应用层来操心。

我写 `crunchbase-ruby-library`，就是为了在这一切上面包一层干净的 Ruby 接口。

## 这个 Gem 做了什么

这个 Gem 封装了 Crunchbase API v3.1，核心提供：

- 处理认证、超时配置和请求生命周期的客户端对象
- 每种实体类型对应的模型类：Organization、Person、Product、IPO、Acquisition、FundingRound
- 把 Ruby Hash 参数转换为 API 查询参数格式的搜索接口
- 支持关系感知的 `get` 方法，一次调用就能获取实体及其关联数据

```ruby
client = Crunchbase::Client.new

# 搜索公司
results = client.search({ name: "Stripe" }, 'organizations')
results.total_items   # => 12
results.results       # => [#<Crunchbase::Model::Organization ...>, ...]

# 获取带关联数据的单个实体
org = client.get('stripe', 'Organization')
org.headquarters      # => 位置对象
org.funding_rounds    # => FundingRound 对象数组
```

配置刻意保持极简：

```ruby
Crunchbase::API.key     = ENV['CRUNCHBASE_API_KEY']
Crunchbase::API.timeout = 60
Crunchbase::API.debug   = false
```

一行配置好，应用里的所有调用就都能用了。

## 设计难题

把外部 API 包装成 Ruby 对象听起来很直接，直到你碰上具体的细节。

**关系数据结构不一致。** Crunchbase 的实体模型有几十种关联类型，而且结构并不统一。有些关联返回数组，有些返回单个对象；有些把摘要数据内联进来，有些需要单独请求。我花在读 API 文档、对着真实 API 写测试上的时间，比写模型代码的时间还多。光是 Organization 的关联列表就有 20 多项：

```
primary_image, founders, current_team, investors, owned_by,
sub_organizations, headquarters, offices, products, categories,
customers, competitors, funding_rounds, acquisitions, ipo...
```

每一项都需要特殊处理。最终我用 `method_missing` 把未知方法调用委托给一个从 API 响应里懒加载的 relationships 哈希，这让模型类保持干净，同时支持自然的 Ruby 访问方式：

```ruby
org.founders          # 未加载时自动获取，返回 PersonSummary 对象
org.funding_rounds    # 未加载时自动获取，返回 FundingRound 对象
```

**批量搜索 API 是另一套。** Crunchbase 增加了一个批量接口，接受最多 10 个请求，返回混合类型的结果数组，包含无效 UUID 对应的错误对象。为这个接口设计干净的 Ruby 接口很棘手——你传入异构的请求类型，得到异构的结果，还夹杂着错误对象。最终创建了一个 `BatchSearch` 模型来包装结果数组，支持迭代成功结果并过滤错误：

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

**限流。** V3.1 有访问频率限制，但触顶之前不会明确告诉你快到了，你收到 429 的时候才知道。Gem 对所有请求加了重试逻辑和指数退避，但花了几次生产事故才把退避时机调准。

## V3 到 V4 的迁移

发布这个 Gem 大约一年后，Crunchbase 宣布废弃 V3.1，转向 V4——一个有全新认证模型、不同实体结构和完全重新设计的搜索接口的版本。

我做了一个自己至今还在想的决定：保留 `crunchbase-ruby-library` 作为 V3.1 封装，另外开了一个新 Gem——`crunchbase4`——专门处理 V4，而不是直接升级。

原因：V4 的差异太大，一次升级几乎会破坏所有方法签名和模型属性。在一个补丁版本号里做这件事对下游用户太不诚实。新 Gem 让 V4 用户有了一个干净的起点，也让现有 V3 用户在计划迁移的同时还能稳定使用。

实际上，这意味着要维护两个 Gem，比我预期的工作量大。但它给下游用户提供了可预期性，而可预期性是库作者最容易被低估的贡献。

## 如果重做

**更积极的错误类型体系。** Gem 对所有 API 失败只抛出一个 `Crunchbase::Error`。一年的生产运行告诉我，调用方需要区分"API Key 无效"（致命，立即报警）、"被限流"（重试）、"实体未找到"（符合预期，优雅处理）和"API 宕机"（熔断）。一个错误类把所有分类判断推给了每一个调用方，一个错误类体系从一开始就会更好。

**更早用录制的 Fixture 来做测试。** 我用了 VCR 来录制 HTTP 交互，但加得太晚。最初的测试直接打真实 API，速度慢，CI 需要凭据，而且 Crunchbase 偶尔改了响应格式就会让测试失效。从一开始就录制所有 API 交互，测试套件会更快也更可靠。

**显式版本化模型。** Crunchbase 在小版本号之间改变了几个响应对象的结构，没有主版本号变更。Gem 的模型假设结构是稳定的，字段被新增或重命名时就静默出错了。显式的 schema 版本化，或者至少用 `dig` 做防御性的属性访问，能更早发现这些问题。

Gem 在 [github.com/encoreshao/crunchbase-ruby-library](https://github.com/encoreshao/crunchbase-ruby-library)，V3.1 API 访问还能用。如果你要对接 V4，相关工作在 [github.com/ekohe/crunchbase4](https://github.com/ekohe/crunchbase4) 继续。
