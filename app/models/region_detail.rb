class RegionDetail
  include Mongoid::Document
  field :zone, type: Integer
  field :countrys_en, type: String
  field :countrys_cn, type: String
  field :name, type: String
  field :transport, type: String
  field :no, type: String

  belongs_to :quoted_parice
end
