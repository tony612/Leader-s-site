# -*- coding: utf-8 -*-

class NewsController < ApplicationController
  skip_before_filter :signed_in_user

  # GET /news
  # GET /news.json
  def index
    #@news = News.all
    #@news = News.where(category: "行业动态")
    @news = News.find_by_category
    @news.each {|news| p "news =========="; p news['value'].values[0].class}
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @news }
    end
  end

  # GET /news/1
  # GET /news/1.json
  def show
    @news = News.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @news }
    end
  end

end
