require 'rails_helper'

RSpec.describe Comment, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
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
