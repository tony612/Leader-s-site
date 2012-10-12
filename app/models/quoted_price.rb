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
  #field doc_head Integer, doc_continue Integer, doc_range Array
  #field small_head Array, small_continue Array, small_range Array
  field :big_range, type: Array
  has_many :region_details

end
