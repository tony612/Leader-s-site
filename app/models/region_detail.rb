class RegionDetail
  include Mongoid::Document
  field :zone, type: Integer
  field :countrys_en, type: Array
  field :countrys_cn, type: Array
  field :no, type: String
  #field :doc_prices, type: Array
  #field :small_prices, type: Array
  #field :big_prices, type: Array
  #field :prices, type: Array
  belongs_to :quoted_price
  
end
