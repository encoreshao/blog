class Admin::CommentsController < AdminController
  defaults resource_class: Comment, collection_name: 'comments', instance_name: 'comment'

  protected
  def permitted_params
    params.fetch(:comment, {}).permit(:content, :user_id)
  end
end
