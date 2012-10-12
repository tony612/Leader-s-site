# -*- coding: utf-8 -*-

require 'spreadsheet'

class Admin::QuotedPricesController < ApplicationController
  before_filter :verify_ability
  # GET /quoted_prices
  # GET /quoted_prices.json
  def index
    @quoted_prices = QuotedPrice.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @quoted_prices }
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
  
  def create_all
    params[:quoted_price][:oil_price] = 1 unless params[:quoted_price][:oil_price].lstrip.rstrip.match(/^\d+$/)
    attachment = Attachment.create(:attachment => params[:attachment]) if params[:attachment]
    p "create all===================================================================="
    Spreadsheet.client_encoding = 'UTF-8'
    tables = Spreadsheet.open "#{Rails.root}/public/uploads/quoted_prices/#{attachment.attachment_filename}"
    tables.worksheets.each do |worksheet|
      create_single(worksheet) if worksheet.cell 0, 0
    end

    redirect_to admin_quoted_prices_path
  end
  
  def create_single(worksheet)
    region_begin, region_end = worksheet.cell(0, 0).to_s.split(/\W/)
    zone_index, country_index = worksheet.cell(0, 1), worksheet.cell(0, 2)
    doc_begin, doc_end = worksheet.cell(0, 3) && worksheet.cell(0, 3).to_s.split(/\W/)
    small_begin, small_end = worksheet.cell(0, 4).to_s.split(/\W/)
    big_begin, big_end = worksheet.cell(0, 5).to_s.split(/\W/)
    data_arr = [region_begin, region_end, zone_index, country_index, doc_begin, doc_end, small_begin, small_end, big_begin, big_end]
    p data_arr
    
    if region_begin.match(/\d+/)
      region_way = "row"
    else
      region_way = "col"
    end
    region_begin, region_end, zone_index, country_index, doc_begin, doc_end, small_begin, small_end, big_begin, big_end = data_arr.map{|c| c = c && letter_to_int(c).to_i}
    if region_way == 'row'
      region_begin -= 1
      region_end -= 1
    elsif region_way == 'col'
      zone_index -= 1 if zone_index
      country_index -= 1 if country_index
      doc_begin -= 1 if doc_begin
      doc_end -= 1 if doc_end
      small_begin -= 1 if small_begin
      small_end -= 1 if small_end
      big_begin -= 1 if big_begin
      big_end -= 1 if big_end
      p "COL==================================+++++++++++++++++++++++++"
      p [zone_index, country_index, doc_begin, doc_end, small_begin, small_end, big_begin, big_end]
    end
    p "Table: #{worksheet.name} =================================================================="
    print "Head====", [region_begin, region_end, zone_index, country_index, doc_begin, doc_end, small_begin, small_end, big_begin, big_end]
    quoted_price = QuotedPrice.new(params[:quoted_price])
    quoted_price.name, quoted_price.transport, quoted_price.doc_type, quoted_price.big_type = worksheet.name, worksheet.name[/UPS|DHL|Fedex/i], !!doc_begin, !small_begin
    if region_way == "row"
      thead = worksheet.row(region_begin - 1)
    else
      thead = worksheet.column(region_begin - 1)
    end
    p "Region way: #{region_way}"
    if region_way == "row"
      #thead = worksheet.row(region_begin - 1)
      quoted_price.small_celling = thead.at(big_begin).scan(/\d+/)[0]
      quoted_price[:doc_head], quoted_price[:doc_continue] = thead.at(doc_begin)[/\d+\.?\d*/], thead.at(doc_end)[/\d+\.?\d*/] if !!doc_begin
      unless quoted_price.big_type
        quoted_price[:small_head] = []
        quoted_price[:small_continue] = []
        quoted_price[:small_range] = []
        (small_begin..small_end).each do |s_index|
          s = thead.at(s_index)
          if s.match('首')
            quoted_price[:small_head] << [s[/\d+\.?\d*/], s_index-small_begin]
          elsif s.match '\+'
            s_celling = thead[s_index+1]
            quoted_price[:small_range] << [s[/\d+\.?\d*/], s_celling[/\d+\.?\d*/], s_index-small_begin, false]
          elsif s.match /(\d+\.?\d*)[^.\d]+(\d+\.?\d*)/
            s_range = s.match /(\d+\.?\d*)[^.\d]+(\d+\.?\d*)/
            quoted_price[:small_range] << [s_range[1], s_range[2], s_index-small_begin, false]
          elsif s.match '续'
            quoted_price[:small_continue] << [s[/\d+\.?\d*/], s_index-small_begin]
          end
        end
      end
      if big_begin
        quoted_price[:big_range] = []
        (big_begin..big_end).each do |b_index|
          b = thead.at(b_index)
          if b.match /(\d+\.?\d*)[^.\d]+(\d+\.?\d*)/
            b_range = b.match /(\d+\.?\d*)[^.\d]+(\d+\.?\d*)/
            b_celling = b == thead[big_end]?  "99999" : b_range[2]
            quoted_price[:big_range] << [b_range[1], b_celling, b_index-big_begin]
          else
            b_celling = b == thead[big_end]?  "99999" : thead[b_index+1]
            quoted_price[:big_range] << [b[/\d+\.?\d*/], b_celling[/\d+\.?\d*/], b_index-big_begin]
          end
        end
      end
      p quoted_price
      (region_begin..region_end).each do |arr_index|
        arr = region_way=='row'? worksheet.row(arr_index) : worksheet.column(arr_index)
        region_detail = RegionDetail.new(zone: (zone_index && arr[zone_index]) || -1, countrys_cn: (country_index && arr[country_index].split(/[,.\-。，]+/)) || "")
        region_detail[:doc_prices], region_detail[:small_prices], region_detail[:big_prices] = [], [], []
        (doc_begin..doc_end).each { |doc_index| region_detail[:doc_prices] << arr.at(doc_index)} if doc_begin
        (small_begin..small_end).each {|s_index| region_detail[:small_prices] << arr.at(s_index)} if small_begin
        (big_begin..big_end).each {|b_index| region_detail[:big_prices] << arr.at(b_index)} if big_begin
        p region_detail if arr_index == region_begin
      end
    end
    # When way is col
    if region_way == 'col'
      quoted_price.small_celling = worksheet.cell(small_end, region_begin-1).to_s.scan(/\d+\.?\d*/)[-1]
      # Has doc type
      if !!doc_begin
        quoted_price[:doc_range] = []
        (doc_begin..doc_end).each do |d_index|
          cell_data = worksheet.row(d_index).at(region_begin-1).to_f
          #quoted_price.doc_range << [worksheet.cell(d_index, region_begin-1).to_s[/\d+\.?\d*/].to_f - 0.5, worksheet.cell(d_index, region_begin-1).to_s[/\d+\.?\d*/].to_f, d_index - doc_begin]
          quoted_price.doc_range << [cell_data - 0.5, cell_data, d_index - doc_begin]
        end
      end
      # Small
      unless quoted_price.big_type
        quoted_price[:small_range] = []
        (small_begin..small_end).each do |s_index|
          cell_data = worksheet.row(s_index).at(region_begin-1)
          #small_head = worksheet.cell(s_index, region_begin-1).to_s[/\d+\.?\d*/].to_f
          small_head = cell_data.to_f
          quoted_price[:small_range] << [small_head - 0.5, small_head, s_index-small_begin]
        end
      end
      # Has big WPX
      if big_begin
        quoted_price[:big_range] = []
        (big_begin..big_end).each do |b_index|
          big_head = worksheet.cell(b_index, region_begin-1).to_s[/\d+\.?\d*/].to_f
          big_head2 = worksheet.cell(b_index, region_begin-2).to_s[/\d+\.?\d*/].to_f
          if worksheet.cell(country_index, region_begin-1).to_s.match '终止' 
            quoted_price[:big_range] << [big_head2, big_head, b_index - big_begin]
          else
            quoted_price[:big_range] << [big_head, worksheet.cell(b_index+1, region_begin-1).to_s[/\d+\.?\d*/].to_f.floor.to_i, b_index-big_begin] unless b_index == big_end
            quoted_price[:big_range] << [big_head, 99999, b_index-big_begin] if b_index == big_end
          end

        end
      end
      p quoted_price
      (region_begin..region_end).each do |arr_index|
        zone_data = worksheet.row(zone_index).at(arr_index) if zone_index
        country_data = worksheet.row(country_index).at(arr_index).split(/[,.\-。，]+/) if country_index
        region_detail = RegionDetail.new(zone: zone_data || -1, countrys_cn: country_data || "")
        region_detail[:doc_prices], region_detail[:small_prices], region_detail[:big_prices] = [], [], []
        (doc_begin..doc_end).each { |d_index| doc_data=worksheet.row(d_index).at(arr_index).round(1);region_detail[:doc_prices] << doc_data} if doc_begin
        (small_begin..small_end).each {|s_index| small_data=worksheet.row(s_index).at(arr_index).round(1);region_detail[:small_prices] << small_data} if small_begin
        (big_begin..big_end).each {|b_index| big_data=worksheet.row(b_index).at(arr_index); big_data=big_data.round(1) if big_data.class!=String;region_detail[:big_prices] << big_data} if big_begin
        p region_detail if arr_index == region_begin
      end

    end
    
  end
  # POST /quoted_prices
  # POST /quoted_prices.json
  def create
    params[:quoted_price][:oil_price] = 1 unless params[:quoted_price][:oil_price].lstrip.rstrip.match(/^\d+$/)
    @quoted_price = QuotedPrice.new(params[:quoted_price])
    
    #p "Attachment ------------------------------------------------"
    #p params[:attachment]
    #@quoted_price[:kind_prices] = params[:kind_of_prices]
    respond_to do |format|
      if @quoted_price.save
        #@quoted_price.create_attachment(:attachment => params[:attachment]) if params[:attachment]
        #handle_table()
        #flash[:success] = "恭喜，成功上传报价表——#{@quoted_price.name}"
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
    params[:quoted_price][:oil_price] = 1 unless params[:quoted_price][:oil_price].lstrip.rstrip.match(/^\d+$/)
    @quoted_price = QuotedPrice.find(params[:id])
    @quoted_price[:kind_prices] = params[:kind_of_prices]
    respond_to do |format|
      if @quoted_price.update_attributes(params[:quoted_price])
        @quoted_price.create_attachment(:attachment => params[:attachment]) if params[:attachment]
        @quoted_price.region_details.delete_all()
        @quoted_price.weight_details.delete_all()
        handle_table()
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


##########
=begin
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
        region.countrys_en = (sheet.cell (rows_arr[2] + region.zone), (cols_arr[2] + 1)).split(%r{[.,\s]\s*})
        region.countrys_cn = (sheet.cell (rows_arr[2] + region.zone), (cols_arr[2] + 2)).split(%r{[.,\s]\s*}) 
        region.no = Time.new.to_formatted_s(:number)
        region.prices = []
        ((rows_arr[0] + 1)..rows_arr[1]).each do |row_index|
          region.prices << sheet.cell(row_index, col_index)
        end
        p "region ============#{region.zone}, #{region.countrys_cn}, #{region.countrys_en}, #{region.no}, #{region.prices}"
        region.save()
        @quoted_price.region_details << region
      end
      weight_index = 0
      ((rows_arr[0] + 1)..rows_arr[1]).each do |row_index|
        weight = WeightDetail.new
        weight[:type], weight[:by_weight], weight[:single_weight], weight[:index] = 
          sheet.cell(row_index, cols_arr[0]), sheet.cell(row_index, cols_arr[0] + 1), sheet.cell(row_index, cols_arr[0] + 2), weight_index
        p "weight detail =================== #{weight.type} #{weight.by_weight} #{weight.single_weight}"
        @quoted_price.weight_details << weight
        weight_index += 1
      end
    when '2'..'3'
      ((rows_arr[0]+1)..rows_arr[1]).each do |row_index|
        row_value = sheet.row row_index
        region = RegionDetail.new
        region.zone = row_value[0]
        region.countrys_en = (sheet.cell (rows_arr[2] + row_value[0]), (cols_arr[2] + 1)).split(%r{[.,\s]\s*})
        region.countrys_cn = (sheet.cell (rows_arr[2] + row_value[0]), (cols_arr[2] + 2)).split(%r{[.,\s]\s*})
        region.no = Time.new.to_formatted_s(:number)
        region[:country], region[:area] = row_value[1].split(%r{[.,\s]\s*}), row_value[2].split(%r{[.,\s]\s*})
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
      weight_index = 0
      row_head[begin_index..(cols_arr[1] - cols_arr[0])].each do |value|
        weight = WeightDetail.new
        weight[:begin], weight[:end], weight[:type], weight[:index] = value[/(\d*)\D*(\d*)/, 1], value[/(\d*)\D*(\d*)/, 2], "WPX", weight_index
        #weight.save()
        p "weight ========================== #{weight.begin} #{weight.end} #{weight.type}"
        @quoted_price.weight_details << weight
        weight_index += 1
      end
    end
  end
=end

  private

  def letter_to_int(arr)
    return arr unless arr && arr.to_s.match(/^[a-zA-Z]*$/)
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
