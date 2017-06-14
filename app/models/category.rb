class Category < ApplicationRecord
end

# == Schema Information
#
# Table name: categories
#
#  id             :integer          not null, primary key
#  name_zh        :string
#  name_en        :string
#  permalink      :string
#  articles_count :integer          default(0)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
