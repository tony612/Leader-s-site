class WeightDetail
  include Mongoid::Document
  field :index, type: Integer 
  embedded_in :quoted_detail
end
