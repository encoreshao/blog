class Kindeditor::Image < Kindeditor::Asset
  mount_uploader :asset, Kindeditor::ImageUploader
end

# == Schema Information
#
# Table name: kindeditor_assets
#
#  id         :integer          not null, primary key
#  asset      :string
#  file_size  :integer
#  file_type  :string
#  owner_id   :integer
#  owner_type :string
#  asset_type :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
