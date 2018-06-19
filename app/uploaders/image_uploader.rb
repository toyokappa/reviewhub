class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def cache_dir
    "tmp/cache/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_whitelist
    %w(jpg jpeg gif png)
  end

  def filename
    "#{secure_token}.jpg" if original_filename.present?
  end

  process convert: "jpg"
  process :fix_rotate
  process resize_to_fill: [400, 400]
  version :thumb do
    process resize_to_fill: [200, 200]
  end

  private

    def fix_rotate
      manipulate! do |img|
        img = img.auto_orient
        img = yield(img) if block_given?
        img
      end
    end

  protected

    def secure_token
      var = :"@#{mounted_as}_secure_token"
      model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
    end
end
