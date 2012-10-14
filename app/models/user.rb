# -*- coding:utf-8 -*-
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::SecurePassword

  field :username, type: String
  field :_id, type: String, default: ->{ username }
  field :name, type: String
  field :email, type: String
  field :address, type: String
  field :password_digest, type: String
  field :admin, type: Boolean
  field :bills_admin, type: Boolean
  field :news_admin, type: Boolean
  field :user_admin, type: Boolean
  field :prices_admin, type: Boolean
  field :remember_token, type: String
  
  validates :username, presence: {message: "用户名不能为空"}, length: {minimum:2, maximum: 20, message: "用户名长度必须在2-20内"}, uniqueness: {message: "用户名已存在"}
  VALID_EMAIL_REGEX = /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  validates :email, presence: {message: "邮箱不能为空"}, format: {with: VALID_EMAIL_REGEX, message: "邮箱格式不正确，应为如：foo@bar.com"}


  has_secure_password
  
  before_save {|user| user.email = email.downcase}
  before_save :create_remember_token

  def ability(item)
    return admin if admin
    p "ability============= #{bills_admin}, #{news_admin}"
    case item
    when 'bills' then bills_admin
    when 'news' then news_admin
    when 'users' then user_admin
    when 'quoted_prices' then prices_admin
    end
  end

  private
    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end

end
