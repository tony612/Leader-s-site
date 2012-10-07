# encoding: utf-8

class AttachmentUploader < CarrierWave::Uploader::Base

  include CarrierWave::MimeTypes
  CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/
  storage :file

  def store_dir
    "uploads/quoted_prices"
  end

  process :set_content_type



end
