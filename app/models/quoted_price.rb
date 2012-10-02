class QuotedPrice
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::MultiParameterAttributes
  field :name, type: String
  field :currency, type: String
  field :transport, type: String
  field :date_active, type: DateTime
  field :kind_prices, type: String
  field :oil_price, type: Float
  field :remark, type: String

  has_many :region_details
  embeds_many :weight_details
  embeds_one :attachment, as: :attachmentable, class_name: 'Attachment', cascade_callbacks: true 

  def country_tokens=(countries)
    
  end
end
