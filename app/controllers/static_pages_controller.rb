class StaticPagesController < ApplicationController
  layout "single", :only => [:about]

  def home
    @news = News.order_by(:created_at.desc, :title.asc).limit(4)
  end

  def about
  end

  def products
  end
end
