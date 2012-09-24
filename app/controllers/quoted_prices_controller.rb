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
    @prices_table = []
    kind_of_prices = @quoted_price.kind_prices
    case kind_of_prices
    when "1"
      thead = []
      thead << "类型" << "截止重" << "单位重"
      regions = @quoted_price.region_details
      regions.each {|region| thead << "分区" + region.zone.to_s}
      p thead
      @prices_table << thead
      weights = @quoted_price.weight_details
      tbody = weights.count.times.map{[]}
      weights.each_index do |index|
        tbody[index] << weights[index][:type] << weights[index][:by_weight] << weights[index][:single_weight]
        regions.each {|region| tbody[index] << region.prices[index]}
      end
      p tbody
      tbody.map {|body| @prices_table << body}
    when '2'..'3'
      thead = []
      thead << "分区" << "国家" << "地区"
      thead << "首重0.5" << "续重0.5" if kind_of_prices == '2'
      weights = @quoted_price.weight_details
      weights.each {|weight| thead << weight.begin + '-' + weight.end}
      @prices_table << thead
      p thead
      regions = @quoted_price.region_details
      tbody = regions.count.times.map{[]}
      regions.each_index do |index|
        tbody[index] << regions[index].zone << regions[index].country << regions[index].area
        tbody[index] << regions[index].head_weight << regions[index].continue_weight if kind_of_prices == '2'
        regions[index].prices.each {|price| tbody[index] << price}
      end
      tbody.map {|body| @prices_table << body}
      

    end

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
  
  def handle_table()
    p "=============quoted prices #{@quoted_price.name}"
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
    case kind_of_prices
    when '1'
      ((cols_arr[0]+3)..cols_arr[1]).each do |col_index|
        region = RegionDetail.new
        region.zone = (sheet.cell rows_arr[0], col_index)[2..-1].to_i
        region.countrys_en = (sheet.cell (rows_arr[2] + region.zone), (cols_arr[2] + 1))
        region.countrys_cn = (sheet.cell (rows_arr[2] + region.zone), (cols_arr[2] + 2)) 
        region.no = Time.new.to_formatted_s(:number)
        region.prices = []
        ((rows_arr[0] + 1)..rows_arr[1]).each do |row_index|
          region.prices << sheet.cell(row_index, col_index)
        end
        p "region ============#{region.zone}, #{region.countrys_cn}, #{region.countrys_en}, #{region.no}, #{region.prices}"
        region.save()
        @quoted_price.region_details << region
      end
      ((rows_arr[0] + 1)..rows_arr[1]).each do |row_index|
        weight = WeightDetail.new
        weight[:type], weight[:by_weight], weight[:single_weight] = 
          sheet.cell(row_index, cols_arr[0]), sheet.cell(row_index, cols_arr[0] + 1), sheet.cell(row_index, cols_arr[0] + 2)
        p "weight detail =================== #{weight.type} #{weight.by_weight} #{weight.single_weight}"
        @quoted_price.weight_details << weight
      end
    when '2'..'3'
      ((rows_arr[0]+1)..rows_arr[1]).each do |row_index|
        row_value = sheet.row row_index
        region = RegionDetail.new
        region.zone = row_value[0]
        region.countrys_en = (sheet.cell (rows_arr[2] + row_value[0]), (cols_arr[2] + 1))
        region.countrys_cn = (sheet.cell (rows_arr[2] + row_value[0]), (cols_arr[2] + 2))
        region.no = Time.new.to_formatted_s(:number)
        region[:country], region[:area] = row_value[1..2]
        region[:head_weight], region[:continue_weight] = *row_value[3..4] if kind_of_prices == "2"
        begin_index = kind_of_prices == '2'? 5 : 3
        region.prices = []
        row_value[begin_index..(cols_arr[1] - cols_arr[0])].map {|value| region.prices << value}
        p "region ============#{region.zone}, #{region.countrys_cn}, #{region.countrys_en}, #{region.no} #{region.country} #{region.area} #{region.prices}"
        @quoted_price.region_details << region
        region.save()
      end
      row_head = sheet.row rows_arr[0]
      begin_index = kind_of_prices == '2'? 5 : 3
      row_head[begin_index..(cols_arr[1] - cols_arr[0])].each do |value|
        weight = WeightDetail.new
        weight[:begin], weight[:end], weight[:type] = value[/(\d*)\D*(\d*)/, 1], value[/(\d*)\D*(\d*)/, 2], "WPX"
        #weight.save()
        p "weight ========================== #{weight.begin} #{weight.end} #{weight.type}"
        @quoted_price.weight_details << weight
      end
    end
  end

  # POST /quoted_prices
  # POST /quoted_prices.json
  def create
    @quoted_price = QuotedPrice.new(params[:quoted_price])
    p "Attachment ------------------------------------------------"
    p params[:attachment]
    @quoted_price[:kind_prices] = params[:kind_of_prices]
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
