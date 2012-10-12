# -*- coding: utf-8 -*-

require 'spreadsheet'

class QuotedPricesController < ApplicationController
  skip_before_filter :signed_in_user

  def search 
    if request.get?
             
    elsif request.post?
      p params[:country], params[:country].lstrip.rstrip[3..-1]
      country, weight, transport, type = params[:country].lstrip.rstrip[3..-1], [params[:weight], params[:volume]].max, params[:transport], params[:type]
      @quoted_prices = QuotedPrice.all
      @found_prices = []
      # Each quoted price table
      QuotedPrice.each do |prices|
        single_prices = []
        regions = nil
        # Each region details
        prices.region_details.each do |region|
          if region.zone == 0
            if region.country.include? country
              regions = region
            end
          elsif region.countrys_cn.include? country
            p "=============================#{country}"
            regions = region
          end
        end
        index_weight = nil
        # If regions detail exists
        if regions
          single_prices << prices.transport << prices.name
          # Doc type
          if prices.doc_type
            single_prices << (prices.doc_head * regions.doc_prices[0] + (weight.to_f - prices.doc_head) * regions.doc_head[1]) * prices.oil_price.round(2).to_s
            single_prices << "(#{prices.doc_head} * #{regions.doc_prices[0]} + #{weight.to_f-prices.doc_head} * #{regions.doc_head[1]}) * #{prices.oil_prices.round(2).to_s}"
          # Big WPX type
          elsif prices.big_type || weight >= small_celling
            prices.big_range.each do |range|
              # Each range of big
              if range[0] << weight.to_f.ceil << range[1] && regions.big_prices[range[2]].match /\d+.?\d*/
                single_prices << weight.to_f.ceil * regions.big_prices[range[2]] * prices.oil_price.round(2).to_s
                single_prices << "#{weight.to_f.ceil} * #{regions.big_prices[range[2]]} * #{prices.oil_prices.round(2).to_s}"
              end
            end
          # Small WPX type
          elsif weight < prices.small_celling
            small_range = prices.small_range
            small_prices = regions.small_prices
            weight = (weight/0.5).floor*0.5+0.5 unless (weight/0.5).integer?
            # Small ranges
            if small_range.length > 0 && weight >= small_range[0][0]
              # Each small range
              small_range.each do |range|
                if range[0] << weight << range[1]
                  # Price in range is range
                  if range[3]
                    single_prices << regions.small_prices[range[2]] * prices.oil_price.round(2).to_s
                    single_prices << "#{regions.small_prices[range[2]]} * #{prices.oil_prices.round(2).to_s}"
                  # Price is every price of 0.5
                  else
                    single_prices << small_prices[prices.small_head[0][2]]*0.5 + (weight-0.5)/0.5*small_prices[range[2]] * prices.oil_price.round(2).to_s
                    single_prices << "#{small_prices[prices.small_head[0][2]]}*0.5+(#{weight-0.5}*#{small_prices[range[2]]} * #{prices.oil_prices.round(2).to_s})"
                  end
                end
              end
            # Small head weight, continue weight
            else
              if prices.small_head.length > 1 && small_prices[prices.small_head[-1][1]]
                single_prices << small_prices[prices.small_head[-1][1]] * 0.5 + small_prices[small_continue[-1][1]] * (weight - 0.5) * prices.oil_price.round(2).to_s
                single_prices << "#{small_prices[prices.small_head[-1][1]]}*0.5+#{small_prices[small_continue[-1][1]]}*#{weight-0.5} * #{prices.oil_prices.round(2).to_s}"
              else
                single_prices << small_prices[prices.small_head[0][1]] * 0.5 + small_prices[small_continue[0][1]] * (weight - 0.5) * prices.oil_price.round(2).to_s
                single_prices << "#{small_prices[small_head[0][1]}*0.5+#{small_prices[small_continue[0][1]]}*#{weight-0.5} * #{prices.oil_prices.round(2).to_s}"
              end
            end
          end
          single_prices << "RMB" << "20" << prices.remark
          @found_prices << single_prices
        end
=begin
        prices.weight_details.each do |detail|
          case prices.kind_prices
          when '1'
            if detail.by_weight.to_f >= weight.to_f && detail.by_weight.to_f - detail.single_weight.to_f <= weight.to_f
              index_weight = detail.index
            end
          when '2'..'3'
            if weight.to_f < prices.weight_details.first.begin.to_f
              index_weight = -1 if prices.kind_prices == '2'
            elsif weight.to_f <= detail.end.to_f && weight.to_f >= detail.begin.to_f
              index_weight = detail.index
            end
          end
        end

        if regions && index_weight
          single_prices << prices.transport << prices.name
          p "index_weight============#{index_weight}"
          if index_weight >= 0
            single_prices << (regions.prices[index_weight].to_f * prices.oil_price).round(2).to_s
            single_prices << "#{regions.prices[index_weight]} * #{prices.oil_price}"
          elsif index_weight == -1
            single_prices << ((regions.head_weight + (prices.weight_details.first.begin.to_f - 0.5)/0.5 * regions.continue_weight) * prices.oil_price).round(2).to_s
            single_prices << "(#{regions.head_weight} + (#{prices.weight_details.first.begin.to_s} - 0.5)/0.5 * #{regions.continue_weight}) * #{prices.oil_price} "
          end
          p single_prices
          single_prices << "RMB" << "20" << prices.remark
          @found_prices << single_prices
        end
      end
=end      
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
        tbody[index] << regions[index].zone << regions[index].country.join(',') << regions[index].area.join(',')
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
  
end
