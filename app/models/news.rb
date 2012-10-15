class News
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title
  field :content
  field :category

  validates_presence_of :title
  validates_presence_of :content

  def self.find_by_category

  end
end
