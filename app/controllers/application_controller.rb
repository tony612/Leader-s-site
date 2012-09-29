# -*- coding: utf-8 -*-

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :signed_in_user

  include SessionsHelper
  
  protected
    
  def verify_ability
    p "verify ability =========================="
    p controller_name
    if signed_in?
      unless current_user.ability controller_name
        flash[:warning] = "对不起，您没有这个权限，如需帮助，请联系管理员"
        redirect_to root_path
      end
    else
      signed_in_user
    end
  end
end
