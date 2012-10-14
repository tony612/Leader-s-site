class Attachment
  include Mongoid::Document
  include Mongoid::Timestamps
  field :file_name, type: String
  field :content_type, type: String
  field :file_size, type: String
  field :attachmentable_type, type: String
  field :attachment, type: String
  
  attr_accessible :file_name, :content_type, :file_size, :attachment

  #embedded_in :attachmentable, polymorphic: true

  mount_uploader :attachment, AttachmentUploader

  before_save :set_attachment_attributes

  protected
  
  def set_attachment_attributes
    p "Set attachment attributes __________________________"
    p attachment
    p self

    if attachment.present? && attachment_changed?
      p "present..."
      self.content_type = attachment.file.content_type
      self.file_size = attachment.file.size
      self.file_name = attachment.file.original_filename
    end
  end
end
