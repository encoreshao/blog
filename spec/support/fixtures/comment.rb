# frozen_string_literal: true

Comment.blueprint do
  commentable { Article.make! }
  content { "Content #{sn}" }
  name { "Name #{sn}" }
  email { "Email #{sn}" }
end
