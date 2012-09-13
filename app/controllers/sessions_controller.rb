# -*- coding: utf-8 -*-

class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.where(username: params[:session][:username]).exists? ? User.find_by(username: params[:session][:username]) : nil
    if user and user.authenticate(params[:session][:password])
      #session[:user_id] = user.id
      sign_in user
      flash[:success] = "你好 #{user.name}"
      redirect_to root_path
    else
      flash[:error] = "输入的帐号或密码有问题，请重新输入"
      render :new
    end
  end

  def destroy
    sign_out
    flash[:success] = "已经登出"
    redirect_to root_url
  end
end
