# encoding: utf-8

# rake db:drop && rake db:create && rake db:migrate && rake db:seed && annotate

user = User.create(email: 'admin@blog.com', password: '123456')
UserProfile.create(name: 'Administrator', user: user)

{
  'Development' => '编程',
  'Life' => '生活',
  'Music' => '音乐',
  'Travel' => '旅游',
  'Work' => '工作',
  'Video' => '视频',
  'Fashion' => '时尚',
  'Audio' => '音频',
  'Chat' => '闲聊',
  'Discussion' => '讨论',
  'Meetup' => '聚会',
  'Embed' => '代码块',
  'Culture' => '文化',
  'Education' => '教育'
}.each do |name_en, name_zh|
  Category.find_or_create_by(name_en: name_en, permalink: name_en.downcase, name_zh: name_zh)
end
