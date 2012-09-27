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

end
