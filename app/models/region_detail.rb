class RegionDetail
  include Mongoid::Document
  field :zone, type: Integer
  field :countrys_en, type: String
  field :countrys_cn, type: String
  field :no, type: String

  belongs_to :quoted_price
  has_many :prices_details
end
