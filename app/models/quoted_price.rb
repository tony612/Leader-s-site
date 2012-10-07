class QuotedPrice
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::MultiParameterAttributes
  field :name, type: String
  field :currency, type: String
  field :transport, type: String
  field :date_active, type: DateTime
  #field :kind_prices, type: String
  field :oil_price, type: Float
  field :remark, type: String
  
  field :doc_type, type: Boolean
  field :big_type, type: Boolean
  field :small_celling, type: Integer
  #field doc_head, doc_continue
  #field small_head, small_continue, small_range
  field :big_range, type: Array
  has_many :region_details
  #embeds_many :weight_details
  #embeds_one :attachment, as: :attachmentable, class_name: 'Attachment', cascade_callbacks: true 

end
