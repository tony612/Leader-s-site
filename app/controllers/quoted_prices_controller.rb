# -*- coding: utf-8 -*-

require 'spreadsheet'

class QuotedPricesController < ApplicationController
  skip_before_filter :signed_in_user

  def search 
    if request.get?
             
    elsif request.post?
      country, weight, transport, type = params[:country].strip[3..-1], [params[:weight], params[:volume]].max, params[:transport], params[:type]
      @quoted_prices = QuotedPrice.all
      @found_prices = []
      weight = weight.to_f
      # Each quoted price table
      QuotedPrice.each do |prices|
        single_prices = []
        result_price = nil
        result_express = nil
        regions = nil
        # Each region details
        prices.region_details.each do |region|
          if region.zone == 0
            if region.countrys_cn.include? country
              regions = region
              p regions
              p prices
            end
          elsif region.countrys_cn.include? country
            p "=============================#{country}"
            regions = region
            p regions
            p prices
          end
        end
        index_weight = nil
        # If regions detail exists
        if regions
          # Doc type
          if type == "DOC"
            if prices.doc_type
              p "=============================doc type"
              weight = (weight/0.5).floor*0.5+0.5 unless (weight.integer? || weight%1 == 0.5)
              if prices.doc_range && prices.doc_range.length > 0
                result_price = (prices.doc_head * regions.doc_prices[0] + (weight.to_f - prices.doc_head) * regions.doc_prices[1]) * prices.oil_price.round(2).to_s
                result_express = "(#{prices.doc_head} * #{regions.doc_prices[0]} + #{weight.to_f-prices.doc_head} * #{regions.doc_prices[1]}) * #{prices.oil_prices.round(2).to_s}"
              else
                prices.doc_range.each do |range|
                  if range[0] < weight && weight < range[1]
                    result_price = regions.doc_prices[range[2]] * prices.oil_prices.round(2).to_s
                    result_express = "#{regions.doc_prices[range[2]]} * #{prices.oil_prices.round(2)}"
                  end
                end
              end
            end
          # Big WPX type

          elsif weight >= prices.small_celling
            p "=============================big type"
            if prices.big_range
              prices.big_range.each do |range|
                p range, weight.ceil, regions.big_prices[range[2]]
                # Each range of big
                if range[0] < weight.ceil && weight.ceil < range[1] && regions.big_prices[range[2]]
                  p weight.ceil, regions.big_prices[range[2]], prices.oil_price.round(2)
                  result_price = (weight.ceil * regions.big_prices[range[2]] * prices.oil_price.round(2)).to_s
                  result_express = "#{weight.ceil} * #{regions.big_prices[range[2]]} * #{prices.oil_price.round(2).to_s}"
                end
                p single_prices
              end
            end
          # Small WPX type
          elsif weight <= prices.small_celling && !prices.big_type
            p "=================================small type"
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
                    result_price = small_prices[prices.small_head[0][2]]*0.5 + (weight-0.5)/0.5*small_prices[range[2]] * prices.oil_price.round(2).to_s
                    result_express = "#{small_prices[prices.small_head[0][2]]}*0.5+(#{weight-0.5}*#{small_prices[range[2]]} * #{prices.oil_prices.round(2).to_s})"
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

      #@countries = 
      respond_to do |format|
        unless @found_prices.empty?
          format.html
          format.js {render :layout => false}
        else
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
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @quoted_price }
    end
  end
  
end
