class PricesDetail
  include Mongoid::Document
  include Mongoid::Timestamps
  field :type, type: String
  field :cal_type, type: Integer
  field :price, type: String

  belongs_to :region_detail
end
