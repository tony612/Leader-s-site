# encoding: utf-8
require 'spreadsheet'

class Bill
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::MultiParameterAttributes
  field :our_no, type: String
  field :intl_no, type: String
  field :tracking_no, type: String
  field :goal, type: String
  field :number, type: Integer
  field :local_time, type: DateTime
  field :new_status, type: String
  field :url, type: String
  field :transport, type: String
  field :user_id, type: Integer
  #validates_presence_of :tracking_no
  #validates_presence_of :intl_no
  #validates_presence_of :transport
  attr_reader :bill_file

  belongs_to :user

  def self.build_by_file(params)
    bill_file = params[:bill_file]
    random_dir = SecureRandom.hex(15)
    base_path = "tmp/sheets/#{random_dir}"
    name = bill_file.original_filename
    name = SecureRandom.hex(16) + '.xls'
    path = File.join(base_path, name)
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, 'wb') {|f| f.write(bill_file.read) }
    Spreadsheet.client_encoding = 'UTF-8'
    tables = Spreadsheet.open "#{Rails.root}/#{path}"

    warning = ""
    @bills = []

    tables.worksheets.each do |worksheet|
      worksheet.each 1 do |row|
        date = row.formatted[0]
        intl_no = row.at(1).try(:to_i).to_s
        tracking_no = row.at(2).try(:to_i).to_s
        goal = row.at(3)
        number = row.at(4).to_s
        transport = row.at(5)
        username = row.at(6)
        url = row.at(7)
        user = User.where({:username => username})
        if transport == "DHL"
          url = "http://www.dhl.com.hk/content/hk/sc/express/tracking.shtml?brand=DHL&AWB=#{tracking_no}"
        end
        fields = {:intl_no => intl_no, :tracking_no => tracking_no, :goal => goal, :number => number, :transport => transport, :url => url}
        if date.class == Date
          fields.merge!({:local_time => date})
        else
          fields.merge!({:local_time => Time.now})
          warning << "时间#{date}格式不对,默认设为当前时间;"
        end
        unless user.blank?
          fields.merge!({:user_id => user[0].id})
        else
          warning << "用户#{username}不存在;"
        end
        @bills << Bill.new(fields)
      end
    end
    FileUtils.rm_rf base_path
    {:bills => @bills, :warning => warning}
  end
end
