class Bill
  include Mongoid::Document
  include Mongoid::Timestamps
  field :our_no, type: String
  field :intl_no, type: String
  field :tracking_no, type: String
  field :goal, type: String
  field :number, type: Integer
  field :local_time, type: Time
  field :new_status, type: String
  field :url, type: String
end
