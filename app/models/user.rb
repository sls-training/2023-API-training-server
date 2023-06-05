# frozen_string_literal: true

class User < ApplicationRecord
  validates :name, presence: true, length: { minimum: 1, maximum: 64 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true

  has_secure_password
  validates :password, presence: true, length: { minimum: 16, maximum: 128 }, allow_nil: true
end
