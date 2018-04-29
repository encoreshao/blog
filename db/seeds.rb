# frozen_string_literal: true

# rake db:drop && rake db:create && rake db:migrate && rake db:seed && annotate

[
  { email: "admin@blog.com", name: "邵壮", password: "123456", is_admin: true },
  { email: "encore@blog.com", name: "Encore Shao", password: "123456" }
].each do |option|
  User.create(option)
end

{
  "Development" => "开发",
  "Life" => "生活",
  "Music" => "音乐",
  "Travel" => "旅游",
  "Work" => "工作",
  "Video" => "视频",
  "Fashion" => "时尚",
  "Audio" => "音频",
  "Chat" => "闲聊",
  "Discussion" => "讨论",
  "Meetup" => "聚会",
  "Culture" => "文化",
  "Education" => "教育",
  "Code" => "编码",
  "Design" => "设计",
  "Business" => "商业",
  "Mobile" => "手机",
  "Social" => "Social"
}.each do |name_en, name_zh|
  Category.find_or_create_by(name_en: name_en, permalink: name_en.downcase, name_zh: name_zh)
end

# (0..20).each do |i|
#   options = {
#     title: "Test - #{i}",
#     permalink: "test-#{i}",
#     content: "TEST - CONTENT - #{i}",
#     is_published: true,
#     published_at: Time.zone.now.to_date,
#     category_id: 1,
#     user_id: User.all.sample.try(:id)
#   }
#   Article.create!(options)
# end
