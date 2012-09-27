# -*- coding: utf-8 -*-

module SessionsHelper

  def sign_in(user)
    cookies.permanent[:remember_token] = user.remember_token
    self.current_user = user
  end
  
  def signed_in?
    current_user
  end

  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
  end
  
  def current_user?(user)
    user = current_user
  end
  
  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end
  
  def store_location
    session[:return_to] = request.url
  end

  def signed_in_user
    unless signed_in?
      store_location
      flash[:warning] = "请先登录！"
      redirect_to login_url
    end
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= User.where(remember_token: cookies[:remember_token]).exists? ? User.find_by(remember_token: cookies[:remember_token]) : nil
  end
end
