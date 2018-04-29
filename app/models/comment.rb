# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :commentable, polymorphic: true

  has_many :comments,
           class_name: "Comment",
           primary_key: "id",
           foreign_key: "comment_id"

  scope :parent_comments, -> { where("comment_id IS NULL") }
  scope :with_keywords, ->(keyword) {
    return nil if keyword.blank?

    criteria = ActiveRecord::Base.send(:sanitize_sql, keyword)
    joins("LEFT JOIN articles ON comments.commentable_id = articles.id")
      .where("LOWER(articles.title) ILIKE LOWER(?)", "%#{criteria}%")
  }

  def user_name
    name || "Anonymous"
  end
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
#  remote_ip        :inet
#  user_id          :integer
#  commentable_type :string
#  commentable_id   :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
