class Bill
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::MultiParameterAttributes
  field :our_no, type: String
  field :intl_no, type: String
  field :tracking_no, type: String
  field :goal, type: String
  field :number, type: Integer
  field :local_time, type: DateTime
  field :new_status, type: String
  field :url, type: String
  field :transport, type: String
  validates_presence_of :tracking_no
  validates_presence_of :intl_no
  validates_presence_of :transport
  
end
