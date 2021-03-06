# -*- coding: utf-8 -*-

class Admin::BillsController < ApplicationController
  before_filter :verify_ability
  # GET /bills
  # GET /bills.json
  def index
    @bills = Bill.order_by(:local_time => :desc).page params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bills }
    end
  end

  # GET /bills/new
  # GET /bills/new.json
  def new
    @bill = Bill.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @bill }
    end
  end

  # GET /bills/1/edit
  def edit
    @bill = Bill.find(params[:id])
  end

  # POST /bills
  # POST /bills.json
  def create
    result = Bill.build_by_file(params[:bill])
    @bills = result[:bills]
    warning = result[:warning]

    respond_to do |format|
      if !@bills.blank? and @bills.each(&:save)
        flash[:success] = "恭喜，运单创建成功  " + warning
        format.html { redirect_to admin_bills_path }
        format.json { render json: @bill, status: :created, location: @bill }
      else
        flash.now[:error] = "对不起，填写信息有误，请重新输入"
        format.html { render action: "new" }
        format.json { render json: @bill.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /bills/1
  # PUT /bills/1.json
  def update
    @bill = Bill.find(params[:id])

    respond_to do |format|
      if @bill.update_attributes(params[:bill])
        flash[:success] = "恭喜，修改已完成"
        format.html { redirect_to admin_bills_path }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @bill.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bills/1
  # DELETE /bills/1.json
  def destroy
    @bill = Bill.find(params[:id])
    @bill.destroy

    respond_to do |format|
      format.html { redirect_to admin_bills_url }
      format.json { head :no_content }
    end
  end

end
