Comment.blueprint do
  commentable { Article.make! }
  content { "Content #{sn}" }
end
