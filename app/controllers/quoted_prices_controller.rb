# -*- coding: utf-8 -*-

require 'spreadsheet'

class QuotedPricesController < ApplicationController

  # GET /quoted_prices
  # GET /quoted_prices.json
  def index
    @quoted_prices = QuotedPrice.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @quoted_prices }
    end
  end

  # GET /quoted_prices/1
  # GET /quoted_prices/1.json
  def show
    @quoted_price = QuotedPrice.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @quoted_price }
    end
  end
  
  def download
    prices = QuotedPrice.find(params[:quoted_price])
    begin
      send_file "#{Rails.root}/public/uploads/attachment/attachment/#{prices.attachment._id}/#{prices.attachment.attachment_filename}"
    rescue
      flash[:error] = "对不起，没有可以下载的报价表"
      redirect_to quoted_prices_path
    end
  end

  # GET /quoted_prices/new
  # GET /quoted_prices/new.json
  def new
    @quoted_price = QuotedPrice.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @quoted_price }
    end
  end

  # GET /quoted_prices/1/edit
  def edit
    @quoted_price = QuotedPrice.find(params[:id])
  end
  
  def handle_table
    prices_rows_begin, prices_rows_end = *(params[:prices_rows_range].split(%r{[.,\s]\s*}))
    prices_cols_begin, prices_cols_end = *(params[:prices_cols_range].split(%r{[.,\s]\s*}))
    area_rows_begin, area_rows_end = *(params[:area_rows_range].split(%r{[.,\s]\s*}))
    area_cols_begin, area_cols_end = *(params[:area_cols_range].split(%r{[.,\s]\s*}))
    p [prices_rows_begin, prices_rows_end, prices_cols_begin, prices_cols_end, area_rows_begin, area_rows_end, area_cols_begin, area_cols_end]
    excel_path = "#{Rails.root}/public/uploads/attachment/attachment/#{@quoted_price.attachment._id}/#{@quoted_price.attachment.attachment_filename}"
    Spreadsheet.client_encoding = 'UTF-8'
    quoted_prices_table = Spreadsheet.open excel_path
    sheet = quoted_prices_table.worksheet 0
    row = sheet.row(prices_rows_begin.to_i)
    row.each do |cell|
      p cell
    end
  end

  # POST /quoted_prices
  # POST /quoted_prices.json
  def create
    @quoted_price = QuotedPrice.new(params[:quoted_price])
    p "Attachment ------------------------------------------------"
    p params[:attachment]
    
    respond_to do |format|
      if @quoted_price.save
        @quoted_price.create_attachment(:attachment => params[:attachment]) if params[:attachment]
        handle_table()     
        flash[:success] = "恭喜，成功上传报价表——#{@quoted_price.name}"

        format.html { redirect_to @quoted_price }
        format.json { render json: @quoted_price, status: :created, location: @quoted_price }
      else
        format.html { render action: "new" }
        format.json { render json: @quoted_price.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /quoted_prices/1
  # PUT /quoted_prices/1.json
  def update
    p params[:id]
    @quoted_price = QuotedPrice.find(params[:id])

    respond_to do |format|
      if @quoted_price.update_attributes(params[:quoted_price])
        @quoted_price.create_attachment(:attachment => params[:attachment]) if params[:attachment]
        flash[:success] = "恭喜，报价表修改完成"
        format.html { redirect_to @quoted_price }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @quoted_price.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /quoted_prices/1
  # DELETE /quoted_prices/1.json
  def destroy
    @quoted_price = QuotedPrice.find(params[:id])
    @quoted_price.destroy

    respond_to do |format|
      format.html { redirect_to quoted_prices_url }
      format.json { head :no_content }
    end
  end
end
