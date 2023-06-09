# frozen_string_literal: true

class AccessToken < ApplicationRecord
  belongs_to :user

  # Bearerトークンとしての利用を想定しているため、フォーマットはBearerトークンのシンタックスを満たす必要がある。
  # https://datatracker.ietf.org/doc/html/rfc6750#section-2.1
  #
  # 上記では、トークンの文字列長は1以上であればよいことになっているが、短すぎると総当たりで突破されないとも
  # 限らないので 保険として、 `=` によるパディング以外の部分に関して、ある程度の長さを要求する。
  validates :token, format: { with: %r{\A[\w\-.~+/]{16,}=*\Z} }, uniqueness: true
  validates :scope, format: { with: /\A(READ|WRITE)( (READ|WRITE))*\Z/ }
  validates :expires_in, numericality: { greater_than_or_equal_to: 0 }

  attribute :token, default: -> { SecureRandom.base64 }
  attribute :scope, default: 'READ WRITE'
  attribute :expires_in, default: 1.hour

  def expired?
    raise 'Save this object before call #expired?' if new_record?

    created_at + expires_in < Time.current
  end

  def revoked?
    revoked_at.present?
  end

  def revoke
    update revoked_at: Time.current if revoked_at.nil?
  end

  def authorized?(required_scope)
    scope.split.member? required_scope
  end
end
