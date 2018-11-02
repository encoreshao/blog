# frozen_string_literal: true

class UploadsController < ApplicationController
  def image
    file = params[:file]
    success = true
    msg = "上传成功"
    file_real_path = ""

    if verify_image?(file)
      success = false
      msg = I18n.t("uploads.image.success", filename: file.original_filename)
    elsif filesize?(file)
      success = false
      msg = I18n.t("uploads.image.bigsize", filename: file.original_filename)
    end

    file_real_path = save_file(file) if success

    render json: {
      success: success,
      msg: msg,
      file_path: "/#{file_real_path}"
    }
  end

  private
    def save_file(file)
      extname = file.content_type.match(/^image\/(gif|png|jpg|jpeg){1}$/).to_a[1]
      # filename = File.basename(file.original_filename,'.*')
      uri = custom_filename(extname)
      save_path = Rails.root.join("public", uri)

      create_folder!(save_path)

      File.open save_path, "wb" do |f|
        f.write(file.read)
      end

      uri
    end

    def create_folder!(save_path)
      file_dir = File.dirname(save_path)

      # Detect the file folder
      FileUtils.mkdir_p(file_dir) unless Dir.exists?(file_dir)
    end

    def custom_filename(extname)
      filename = "#{DateTime.now.strftime('%Y/%m%d/%H%M%S')}_#{SecureRandom.hex(4)}_#{current_user.id}.#{extname}"

      File.join("uploads", "images", filename)
    end

    def verify_image?(file)
      !file.content_type.match(/^image\/(gif|png||jpg||jpeg|){1}$/)
    end

    def filesize?(file)
      file.size > 2 * 1024 * 1024
    end
end
