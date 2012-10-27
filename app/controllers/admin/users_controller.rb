# -*- coding: utf-8 -*-

class Admin::UsersController < ApplicationController
  skip_before_filter :signed_in_user
  before_filter :verify_ability, except: [:new, :create]
  # GET /users
  # GET /users.json
  def index
    if current_user.ability 'super'
      @users = User.asc(:username).page params[:page]
    elsif current_user.ability 'users'
      @users = User.all.nin(admin: true, user_admin: true)
    end
    @users.each {|user| p user}

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    unless current_user.ability 'super'
      params[:user][:admin] = false
      params[:user][:user_admin] = false
    end
    @user = User.new(params[:user])
  
    respond_to do |format|
      if @user.save
        flash[:success] = "恭喜，用户创建成功"
        format.html { redirect_to admin_users_path }
        format.json { render json: @user, status: :created, location: @user }
      else
        error_msg = ""
        error_msg += @user.errors.messages[:username]*'<br/>' if @user.errors.messages.has_key?(:username)
        error_msg += '<br/>' + @user.errors.messages[:email]*'<br/>' if @user.errors.messages.has_key?(:email)
        error_msg += '<br/>密码不能为空，且两次输入的密码必须一致' if @user.errors.messages.has_key?(:password)
        #@user.errors.messages.push(:password => "密码输入有误") if @user.errors.messages.has_key?(:password_digest)
        flash.now[:error] = error_msg
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])
    unless current_user.ability 'super'
      params[:user][:admin] = false
      params[:user][:user_admin] = @user.user_admin if params[:user][:user_admin] != @user.user_admin
    end

    respond_to do |format|
      if @user.update_attributes(params[:user])
        if @user.id == current_user.id
          flash[:success] = "恭喜，资料更新成功，因为修改了自己的帐号，为了安全，请重新登录"
          path = login_path
        else 
          flash[:success] = "恭喜您，更新成功"
          path = admin_users_path
        end
        format.html { redirect_to path }
        format.json { head :no_content }
      else
        flash[:error] = "对不起，修改失败，请重新输入"
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy if (current_user.ability('super') || current_user.alility('users'))

    respond_to do |format|
      format.html { redirect_to admin_users_url }
      format.json { head :no_content }
    end
  end

end
