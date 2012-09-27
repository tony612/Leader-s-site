# -*- coding: utf-8 -*-

class BillsController < ApplicationController
  skip_before_filter :signed_in_user
  # POST /bills
  def search

    nos = params[:intl_no].split("\r\n")
    p nos
    @bill = Bill.in(intl_no: nos)
    
    respond_to do |format|
      if @bill && @bill.length > 0
        format.html # show.html.erb
        format.json { render json: @bill }
      else
        flash[:warning] = "对不起，没有您要查找的运单号"
        format.html {redirect_to root_path}
      end
    end
  end

end
