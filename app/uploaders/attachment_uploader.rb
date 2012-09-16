# encoding: utf-8

class AttachmentUploader < CarrierWave::Uploader::Base

  include CarrierWave::MimeTypes
  CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/
  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  process :set_content_type



end
