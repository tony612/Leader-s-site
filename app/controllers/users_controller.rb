# -*- coding: utf-8 -*-

class UsersController < ApplicationController
  skip_before_filter :signed_in_user

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  def new
    @user = User.new
  end
  
  def create
    params[:user][:admin], params[:user][:user_admin],params[:user][:bills_admin], params[:user][:news_admin], params[:user][:prices_admin] = false, false, false, false, false
    @user = User.new(params[:user])
  
    respond_to do |format|
      if @user.save
        flash[:success] = "恭喜，用户创建成功"
        sign_in @user
        format.html { redirect_to @user }
        format.json { render json: @user, status: :created, location: @user }
      else
        flash[:error] = "对不起，输入错误，请重新输入"
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
end
