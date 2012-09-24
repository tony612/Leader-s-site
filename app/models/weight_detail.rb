class WeightDetail
  include Mongoid::Document
  
  embedded_in :quoted_detail
end
