class RegionDetail
  include Mongoid::Document
  field :zone, type: Integer
  field :countrys_en, type: Array
  field :countrys_cn, type: Array
  field :no, type: String
  field :prices, type: Array
  belongs_to :quoted_price
  #embeds_many :prices_details
end
