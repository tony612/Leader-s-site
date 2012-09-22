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
    kind_of_prices = params[:kind_of_prices]
    prices_rows_begin, prices_rows_end = *(params[:prices_rows_range].split(%r{[.,\s]\s*}))
    prices_cols_begin, prices_cols_end = *(params[:prices_cols_range].split(%r{[.,\s]\s*}))
    area_rows_begin, area_rows_end = *(params[:area_rows_range].split(%r{[.,\s]\s*}))
    area_cols_begin, area_cols_end = *(params[:area_cols_range].split(%r{[.,\s]\s*}))
    #p [prices_rows_begin, prices_rows_end, prices_cols_begin, prices_cols_end, area_rows_begin, area_rows_end, area_cols_begin, area_cols_end]
    excel_path = "#{Rails.root}/public/uploads/attachment/attachment/#{@quoted_price.attachment._id}/#{@quoted_price.attachment.attachment_filename}"
    Spreadsheet.client_encoding = 'UTF-8'
    quoted_prices_table = Spreadsheet.open excel_path
    sheet = quoted_prices_table.worksheet 0 
    rows_arr = [prices_rows_begin, prices_rows_end, area_rows_begin, area_rows_end].map(&:to_i).map(&:pred) 
    cols_arr = [prices_cols_begin, prices_cols_end, area_cols_begin, area_cols_end].map{|l| letter_to_int(l)}
    #p rows_arr
    #p cols_arr
    case kind_of_prices
    when 1
      ((cols_arr[0]+3)..cols_arr[1]).each do |col_index|
        region = RegionDetail.new
        region.zone = (sheet.cell rows_arr[0], col_index)[2..-1].to_i
        region.contrys_en = (sheet.cell (rows_arr[2] + region.zone), (cols_arr[2] + 1))
        region.contrys_cn = (sheet.cell (rows_arr[2] + region.zone), (cols_arr[2] + 2))
        p "region ============#{region}" 
        region.no = current().to_formatted_s(:number)
        ((rows_arr[0] + 1)..rows_arr[1]).each do |row_index|
          prices_detail = PricesDetail.new(type: sheet.cell(row_index, cols_arr[0]), 
                                           cal_type: kind_of_prices, price: sheet.cell(row_index, col_index))
          prices_detail[:by_weight] = sheet.cell(row_index, cols_arr[0] + 1)
          prices_detail[:single_weight] = sheet.cell(row_index, cols_arr[0] + 2)
          region.prices_details << prices_detail
          p "prices detail ===============" + prices_details
        end
      end
    when 2..3
      ((rows_arr[0]+1)..rows_arr[1]).each do |row_index|
        row_value = sheet.row row_index
        region.zone = row_value[0]
        region.countrys_en = (sheet.cell (rows_arr[2] + row_value[0]), (cols_arr[2] + 1))
        region.countrys_cn = (sheet.cell (rows_arr[2] + row_value[0]), (cols_arr[2] + 2))
        region.no = current().to_formatted_s(:number)
        p "region ===================#{region}"
        ((cols_arr[0]+5)..cols_arr[1]).each do |col_index|
          prices_detail = PricesDetail.new(type: "WPX", cal_type: kind_of_prices, price: sheet.cell(row_value[col_index - cols_arr[0]]))
          prices_detail[:country], prices_detail[:area] = *row_value[1..2]
          prices_detail[:head_weight], prices_detail[:continue_weight] = *row_value[3..4] if kind_of_prices is 2
          region.prices_details << prices_detail
          p "region ============================#{region}"
        end
      end
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

  private

  def letter_to_int(arr)
    arr = arr.upcase
    value = 0
    time = arr.length - 1
    arr.each_byte do |c|
      value += (c - 64) * 26**time
      time -= 1
    end
    value - 1
  end 


end
