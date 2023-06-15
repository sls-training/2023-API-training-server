# frozen_string_literal: true

class User < ApplicationRecord
  has_many :access_tokens, dependent: :destroy

  validates :name, presence: true, length: { minimum: 1, maximum: 64 }

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  before_save { email.downcase! }

  has_secure_password validations: false
  validates :password, presence: true, length: { minimum: 16, maximum: 128 }

  def new_access_token(token: SecureRandom.base64, scope: 'READ WRITE', expires_in: 1.hour)
    access_token = AccessToken.new(token:, scope:, expires_in:)
    access_tokens << access_token
    access_token
  end
end
