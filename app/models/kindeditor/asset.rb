# frozen_string_literal: true

class Kindeditor::Asset < ActiveRecord::Base
  self.table_name = "kindeditor_assets"
  mount_uploader :asset, Kindeditor::AssetUploader
  validates_presence_of :asset
  before_save :update_asset_attributes

  private

    def update_asset_attributes
      if asset.present? && asset_changed?
        self.file_size = asset.file.size
        self.file_type = asset.file.content_type
      end
    end
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
