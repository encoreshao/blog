class Admin::ArticlesController < AdminController
  defaults resource_class: Article, collection_name: 'articles', instance_name: 'article'

  protected
  def article_params
    params.fetch(:article, {}).permit(:title, :permalink, :category_id, :user_id, :published_at, :is_published, :content, :reprinted_source, :reprinted_link)
  end
end
