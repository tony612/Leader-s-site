class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::SecurePassword

  field :username, type: String
  field :name, type: String
  field :email, type: String
  field :address, type: String
  field :password_digest, type: String
  field :admin, type: Boolean
  field :bill_admin, type: Boolean
  field :remember_token, type: String

  has_secure_password
  
  before_save {|user| user.email = email.downcase}
  before_save :create_remember_token

  private
    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end
end
