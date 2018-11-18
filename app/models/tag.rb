# frozen_string_literal: true

class Tag < ApplicationRecord
  include Searchable

  validates :name, :permalink, presence: true, uniqueness: true

  has_and_belongs_to_many :articles
end

# == Schema Information
#
# Table name: tags
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  permalink  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
