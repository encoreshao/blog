Article.blueprint do
  user { User.make! }
  category { Category.make! }
  title { "Title #{sn}" }
  permalink { "Permalink #{sn}" }
  content { "Content #{sn}" }
end
