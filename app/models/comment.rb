class Comment < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :commentable, polymorphic: true

  belongs_to :comment,
             class_name: 'Comment',
             primary_key: 'id',
             foreign_key: 'comment_id',
             optional: true

  scope :parent_comments, -> { where('comment_parent = ?', 0) }
end

# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  content          :text
#  comment_id       :integer
#  comment_parent   :integer          default(0)
#  name             :string
#  email            :string
#  link             :string
#  user_id          :integer
#  commentable_type :string
#  commentable_id   :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
