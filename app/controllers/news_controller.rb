# -*- coding: utf-8 -*-

class NewsController < ApplicationController
  skip_before_filter :signed_in_user

  # GET /news
  # GET /news.json
  def index
    @news = News.find_by_category
    @news_hash = {}
    @news.each do |news|
      value = news['value'].values[0]
      @news_hash[news['_id']] = []
      if value.class == Hash
        @news_hash[news['_id']] << {title: value['title'], id: value['_id'], created_at: value['created_at'] && value['created_at'].to_date.to_formatted_s(:db)}
      else
        value.each do |one|
          one_news = one['news']
          @news_hash[news['_id']] << {title: one_news['title'], id: one_news['_id'], created_id: one_news['created_at'] && one_news['created_at'].to_date.to_formatted_s(:db)}
        end
      end
    end
    p @news_hash
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
