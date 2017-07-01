class Admin::ArticlesController < AdminController
  defaults resource_class: Article, collection_name: 'articles', instance_name: 'article'
  before_action :associate_tags, only: [:update]
  before_action :parameterize_permalink!, only: [:create, :update]
  before_action :verify_permit?, except: [:index, :new]

  protected
  def article_params
    params.fetch(:article, {}).permit(
    	:title, :permalink, :category_id, :user_id, :published_at,
    	:is_published, :content, :reprinted_source, :reprinted_link,
    	:tags, :embed_link
    )
  end

  def parameterize_permalink!
    if params[:article][:permalink].blank? && !params[:article][:title].blank?
      params[:article][:permalink] = params[:article][:title].parameterize
    end
  end

  def associate_tags
  	tags = params[:article].delete(:tags).split(',').map { |e| e.strip }

  	build_tags(tags, resource)
  end

  def build_tags(tags, resource)
  	return if tags.empty?

    tags.each do |name|
      tag = Tag.where("LOWER(name) ILIKE LOWER(?)", name).first
      tag = Tag.create(name: name, permalink: name.downcase) if tag.nil?

			ArticlesTag.find_or_create_by(article_id: resource.try(:id), tag_id: tag.id) if resource.present?
		end
  end

  def collection
    @articles ||= end_of_association_chain.with_owner(current_user).with_keywords(params[:name]).page(params[:page])
  end

  def verify_permit?
    redirect_to admin_articles_path unless admin? || resource.user_id == current_user.id
  end
end
