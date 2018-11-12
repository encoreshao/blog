# frozen_string_literal: true

RSpec.describe Comment do
  let (:comment) { Comment.make! }

  it "Should be with content when create comment" do
    expect(comment.content.present?).to be_truthy
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
