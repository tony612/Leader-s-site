# -*- coding: utf-8 -*-

class SessionsController < ApplicationController
  skip_before_filter :signed_in_user

  def new
  end

  def create
    user = User.where(username: params[:session][:username]).exists? ? User.find_by(username: params[:session][:username]) : nil
    if user and user.authenticate(params[:session][:password])
      sign_in user
      flash[:success] = "你好 #{user.name}"
      redirect_back_or root_path
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
