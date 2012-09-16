class QuotedPrice
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::MultiParameterAttributes
  field :name, type: String
  field :currency, type: String
  field :transport, type: String
  field :date_active, type: DateTime

  has_many :region_details

  embeds_one :attachment, as: :attachmentable, class_name: 'Attachment', cascade_callbacks: true 
end
