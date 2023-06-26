# frozen_string_literal: true

class User < ApplicationRecord
  has_many :access_tokens, dependent: :destroy
  has_many :files, class_name: 'Item', dependent: :destroy

  validates :name, presence: true, length: { minimum: 1, maximum: 64 }

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  before_save { email.downcase! }

  has_secure_password validations: false
  validates :password, presence: true, length: { minimum: 16, maximum: 128 }
end
