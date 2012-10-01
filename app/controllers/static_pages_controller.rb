class StaticPagesController < ApplicationController
  skip_before_filter :signed_in_user

  #layout "single", :only => [:about]

  def home
    @news = News.order_by(:created_at.desc, :title.asc).limit(5)
    #@news = News.find()
  end

  def about
    @item = params[:item]? params[:item] : 'guanyuwomen'

    respond_to do |format|
      format.html
      format.js
    end
  end

  def products
    @item = params[:item]? params[:item] : 'dhl'

    respond_to do |format|
      format.html
      format.js
    end
  end
end
