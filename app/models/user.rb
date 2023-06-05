# frozen_string_literal: true

class User < ApplicationRecord
  validates :name, presence: true, length: { minimum: 1, maximum: 64 }

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  before_save { email.downcase! }

  has_secure_password

  # nil値は has_secure_password() と validate_presence_of() の両方で検知され、同じ内容のエラーが同時に複数発生する。
  # これを防ぐために、オプションに allow_nil : true を指定して validate_presence_of() によるnil値の検出を回避する。
  validates :password, presence: true, length: { minimum: 16, maximum: 128 }, allow_nil: true

  # NOTE: XXX_confirmation 属性が nil になっている場合、パスワード関連のバリデーションが実行されない。そのため、
  # User モデルにパスワードを設定する場合は、パスワード用の属性だけでなく XXX_confirmation にも同時に値を設定してから
  # バリデーションを実行する必要がある。
  #
  # user.password = user.password_confirmation = 'password'
  # user.valid?
  #
  # https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password
  validates :password_confirmation, presence: true
end
