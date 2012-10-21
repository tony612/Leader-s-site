# -*- coding: utf-8 -*-

require 'spreadsheet'

class QuotedPricesController < ApplicationController
  skip_before_filter :signed_in_user

  def search 
    #if request.get?
    #elsif request.post?
    if params[:country] && (params[:weight] || params[:volume] || (params[:length] && params[:height] && params[:width])) && params[:transport] && params[:type]
      country, weight, transport, type = 
        params[:country].strip[3..-1], 
        [params[:weight].to_f, params[:volume].to_f, 
          (params[:length].to_f*params[:height].to_f*params[:width].to_f)/5000].max, params[:transport], params[:type]
      @quoted_prices = QuotedPrice.all
      @found_prices = []
      weight = weight.to_f
      p weight
      # Each quoted price table
      QuotedPrice.each do |prices|
        if transport != "任意" && transport != prices.transport
          next
        end
        single_prices = []
        result_price = nil
        result_express = nil
        regions = nil
        # Each region details
        prices.region_details.each do |region|
          if region.zone == 0
            if region.countrys_cn.include? country
              regions = region
              #p regions
              #p prices
            end
          elsif region.countrys_cn.include? country
            regions = region
            #p regions
            #p prices
          end
        end
        index_weight = nil
        # If regions detail exists
        if regions
          # Doc type
          if type == "DOC"
            if prices.doc_type
              p "=============================doc type #{prices.name}"
              weight = (weight/0.5).floor*0.5+0.5 unless (weight.integer? || weight%1 == 0.5)
              unless prices.respond_to? :doc_range || prices.doc_range.length > 0
                result_price = (prices.doc_head * regions.doc_prices[0] + (weight.to_f - prices.doc_head) * regions.doc_prices[1]) * prices.oil_price.round(2)
                result_express = "(#{prices.doc_head} * #{regions.doc_prices[0]} + #{weight.to_f-prices.doc_head} * #{regions.doc_prices[1]}) * #{prices.oil_price.round(2)}"
              else
                prices.doc_range.each do |range|
                  if range[0] < weight && weight < range[1]
                    result_price = regions.doc_prices[range[2]] * prices.oil_price.round(2)
                    result_express = "#{regions.doc_prices[range[2]]} * #{prices.oil_price.round(2)}"
                  end
                end
              end
            end
          # Big WPX type

          elsif weight >= prices.small_celling
            p "=============================big type #{prices.name}"
            p prices
            p regions
            if prices.big_range
              prices.big_range.each do |range|
                #p range, weight.ceil, regions.big_prices[range[2]]
                # Each range of big
                #p regions.big_prices[range[2]].to_s
                #p range[0] < weight.ceil && weight.ceil < range[1] && regions.big_prices[range[2]].to_s.match(/\d+\.?\d*/)

                if range[0] < weight.ceil && weight.ceil < range[1] && regions.big_prices[range[2]].to_s.match(/\d+\.?\d*/)
                  #p weight.ceil, regions.big_prices[range[2]], prices.oil_price.round(2)
                  result_price = (weight.ceil * regions.big_prices[range[2]] * prices.oil_price).round(2).to_s
                  result_express = "#{weight.ceil} * #{regions.big_prices[range[2]]} * #{prices.oil_price.round(2).to_s}"
                end
                #p single_prices
              end
            end
          # Small WPX type
          elsif weight <= prices.small_celling && !prices.big_type
            p "=================================small type #{prices.name}"
            small_prices = regions.small_prices
            small_range = prices.small_range
            weight = (weight/0.5).floor*0.5+0.5 unless (weight.integer? || weight%1 == 0.5)
            # Small ranges
            if small_range.length > 0 && weight >= small_range[0][0]
              small_range = prices.small_range
              # Each small range
              small_range.each do |range|
                if range[0] < weight && weight < range[1]
                  # Price in range is range
                  if range[3]
                    result_price = regions.small_prices[range[2]] * prices.oil_price.round(2)
                    result_express = "#{regions.small_prices[range[2]]} * #{prices.oil_price.round(2)}"
                  # Price is every price of 0.5
                  else
                    result_price = (small_prices[prices.small_head[0][-1]]*0.5 + (weight-0.5)/0.5*small_prices[range[2]] * prices.oil_price.round(2)).to_s
                    result_express = "#{small_prices[prices.small_head[0][-1]]}*0.5+(#{weight-0.5}*#{small_prices[range[2]]} * #{prices.oil_price.round(2).to_s})"
                  end
                end
              end
            # Small head weight, continue weight
            else
              if prices.small_head.length > 1 && small_prices[prices.small_head[-1][1]] != 0
                small_continue = prices.small_continue
                result_price = (small_prices[prices.small_head[-1][-1]] * 0.5 + small_prices[small_continue[-1][-1]] * (weight - 0.5) * prices.oil_price.round(2)).to_s
                result_express = "#{small_prices[prices.small_head[-1][-1]]}*0.5+#{small_prices[small_continue[-1][-1]]}*#{weight-0.5} * #{prices.oil_price.round(2).to_s}"
              else
                result_price = (small_prices[prices.small_head[0][1]] * 0.5 + small_prices[prices.small_continue[0][1]] * (weight - 0.5) * prices.oil_price.round(2)).to_s
                result_express = "#{small_prices[prices.small_head[0][1]]}*0.5+#{small_prices[prices.small_continue[0][1]]}*#{weight-0.5} * #{prices.oil_price.round(2).to_s}"
              end
            end
          end
          if result_price && result_express
            single_prices << prices.transport << prices.name << result_price << result_express << "RMB" << prices.remark
            @found_prices << single_prices
          end
        end
      end
      @found_prices = Kaminari.paginate_array(@found_prices).page(params[:page]).per(10)
      #@countries = 
      respond_to do |format|
        unless @found_prices.empty?
          format.html
          format.js {render :layout => false}
        else
          @not_found = true
          format.html
          format.js {render :layout => false}
        end
      end
    end
  end

  # GET /quoted_prices/1
  # GET /quoted_prices/1.json
  def show
    @quoted_price = QuotedPrice.find(params[:id])
    @prices_table = []
    thead = []
    # Table head
    thead << "区域" << "国家名称"
    # Doc
    [@quoted_price.doc_head].flatten.each{|h| thead << "首重#{h}"} if @quoted_price.respond_to? :doc_head
    [@quoted_price.doc_continue].flatten.each{|c| thead << "续重#{c}"} if @quoted_price.respond_to? :doc_continue
    @quoted_price.doc_range.each{|r| thead << "#{r[0]}-#{r[1]}"} if @quoted_price.respond_to? :doc_range
    @quoted_price.small_head.each{|h| thead << "首重#{h[0]}"} if @quoted_price.respond_to? :small_head
    @quoted_price.small_continue.each{|c| thead << "续重#{c}"} if @quoted_price.respond_to? :small_continue
    @quoted_price.small_range.each{|r| thead << "#{r[0]}-#{r[1]}"} if @quoted_price.respond_to? :small_range
    @quoted_price.big_range.each{|r| thead << "#{r[0]}-#{r[1]}"} if @quoted_price.respond_to? :big_range
    @prices_table << thead
    @quoted_price.region_details.each do |region|
      row = [region.zone==-1? "无":region.zone, region.countrys_cn * ',']
      row += region.doc_prices if region.respond_to? :doc_prices
      row += region.small_prices if region.respond_to? :small_prices
      row += region.big_prices if region.respond_to? :big_prices
      @prices_table << row
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @quoted_price }
    end
  end
  
end
