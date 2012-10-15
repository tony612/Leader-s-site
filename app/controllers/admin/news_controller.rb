# -*- coding: utf-8 -*-

class Admin::NewsController < ApplicationController
  before_filter :verify_ability
  # GET /news/new
  # GET /news/new.json
  def new
    @news = News.new
    @cats = News.all.distinct(:category)
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @news }
    end
  end

  # GET /news/1/edit
  def edit
    @news = News.find(params[:id])
    @cats = News.all.distinct(:category)
  end

  # POST /news
  # POST /news.json
  def create
    params[:news][:category] = "默认" if params[:news][:category] == ""
    @news = News.new(params[:news])

    respond_to do |format|
      if @news.save
        flash[:success] = "恭喜。新闻创建成功"
        format.html { redirect_to news_index_path(id: @news.id) }
        format.json { render json: @news, status: :created, location: @news }
      else
        flash.now[:error] = "对不起，输入有误。请重新输入"
        format.html { render action: "new" }
        format.json { render json: @news.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /news/1
  # PUT /news/1.json
  def update
    params[:news][:category] = "默认" if params[:news][:category] == ""
    @news = News.find(params[:id])
    
    respond_to do |format|
      if @news.update_attributes(params[:news])
        flash[:success] = "恭喜，新闻修改成功"
        format.html { redirect_to news_index_path(:id => @news.id) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @news.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /news/1
  # DELETE /news/1.json
  def destroy
    @news = News.find(params[:id])
    @news.destroy

    respond_to do |format|
      format.html { redirect_to news_index_path }
      format.json { head :no_content }
    end
  end

end
