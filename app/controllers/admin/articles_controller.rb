class Admin::ArticlesController < AdminController
  defaults resource_class: Article, collection_name: 'articles', instance_name: 'article'
  before_action :associate_tags, only: [:update]
  before_action :parameterize_permalink!, only: [:create, :update]

  protected
  def article_params
    params.fetch(:article, {}).permit(
    	:title, :permalink, :category_id, :user_id, :published_at,
    	:is_published, :content, :reprinted_source, :reprinted_link,
    	:tags
    )
  end

  def parameterize_permalink!
    params[:article][:permalink] = params[:article][:title].parameterize if params[:article][:permalink].blank? && !params[:article][:title].blank?
  end

  def associate_tags
  	tags = params[:article].delete(:tags).split(',').map { |e| e.strip }

  	build_tags(tags, resource)
  end

  def build_tags(tags, resource)
  	return if tags.empty?

		tags.each do |name|
      tag = Tag.where("LOWER(name) ILIKE LOWER(?)", name).first
      if tag.nil?
        tag = Tag.create(name: name, permalink: name.downcase)
      end

			ArticlesTag.find_or_create_by(article_id: resource.try(:id), tag_id: tag.id) if resource.present?
		end
  end

  def collection
    @articles ||= end_of_association_chain.with_keywords(params[:name]).page(params[:page])
  end
end
