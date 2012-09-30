# -*- coding: utf-8 -*-

class NewsController < ApplicationController
  skip_before_filter :signed_in_user

  # GET /news
  # GET /news.json
  def index
    #news_moped = News.find_by_category
    
    @news_hash = Hash.new()
    news = News.all
    news.each do |one_news|
      @news_hash[one_news.category] = [] unless @news_hash.has_key? one_news.category
      @news_hash[one_news.category] << {title: one_news.title, id: one_news.id, created_at: one_news.created_at}
    end
    p @news_hash.first
    id = params[:id]? params[:id] : @news_hash.first[1][0][:id]
    @news = News.find(id)
    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  # GET /news/1
  # GET /news/1.json
  def show
    @news = News.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @news }
    end
  end

end
