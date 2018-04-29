# frozen_string_literal: true

ArticlesTag.blueprint do
  tag { Tag.make! }
  article { Article.make! }
end
