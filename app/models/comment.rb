# frozen_string_literal: true

class Comment < ApplicationRecord
  validates :name, :email, :content, presence: true

  belongs_to :user, optional: true
  belongs_to :commentable, polymorphic: true, optional: true

  has_many :comments,
           class_name: "Comment",
           primary_key: "id",
           foreign_key: "comment_id"

  scope :parent_comments, -> { where(comment_id: nil) }
  scope :fuzzy_search, ->(keyword) {
    return nil if keyword.blank?

    criteria = ActiveRecord::Base.send(:sanitize_sql, keyword)
    joins("LEFT JOIN articles ON comments.commentable_id = articles.id")
      .where("LOWER(articles.title) ILIKE LOWER(?)", "%#{criteria}%")
  }
  scope :sorting, -> { order(created_at: :desc) }
  scope :messages, -> { where(commentable_id: nil) }

  def user_name
    name || "Anonymous"
  end
end

# == Schema Information
#
# Table name: comments
#
#  id               :bigint(8)        not null, primary key
#  comment_parent   :integer          default(0)
#  commentable_type :string
#  content          :text
#  email            :string
#  link             :string
#  name             :string
#  remote_ip        :inet
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  comment_id       :integer
#  commentable_id   :bigint(8)
#  user_id          :bigint(8)
#
# Indexes
#
#  index_comments_on_commentable_type_and_commentable_id  (commentable_type,commentable_id)
#  index_comments_on_user_id                              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
