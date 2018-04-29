# frozen_string_literal: true

# encoding; utf-8

class AvatarUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  version :large do
    process resize_to_fit: [230, 230]
    # process :add_text!
  end

  # Create different versions of your uploaded files:
  version :thumb do
    process resize_to_fit: [100, 100]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_whitelist
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

  # 打水印的位置可以是
  #   'Center', 'NorthWest', 'North', 'NorthEast', 'West', 'Center', 'East', 'SouthWest', 'South', 'SouthEast'
  def add_text!
    text      = (model.name || "ICMOC").force_encoding(Encoding::UTF_8)
    color     = "#0aa4d3"
    position  = "Center"

    manipulate! do |image|
      image.combine_options do |c|
        c.gravity position
        c.fill color
        c.pointsize "24"
        c.draw "text 10,10 '#{text}'"
      end
      image
    end
  end

  def make_watermark(watermark)
    manipulate! do |img|
      img = img.composite(MiniMagick::Image.open(watermark, "jpg")) do |c|
        c.gravity "SouthEast"
      end
      img = yield(img) if block_given?
      img
    end
  end
end
