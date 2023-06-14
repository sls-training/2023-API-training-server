# frozen_string_literal: true

class AccessToken < ApplicationRecord
  belongs_to :user

  # 本来であればトークン文字列はなんでもよいが、短すぎると総当たりで突破されないとも限らないので
  # 保険としてある程度の長さを要求する。
  validates :token, presence: true, length: { minimum: 16 }, uniqueness: true
  validates :scope, format: { with: /\A(READ|WRITE)( (READ|WRITE)*)\Z/ }
  validates :expires_in, numericality: { greater_than_or_equal_to: 0 }

  def expires?
    created_at + expires_in < Time.current
  end

  def revoked?
    !revoked_at.nil?
  end

  def revoke
    update revoked_at: Time.current if revoked_at.nil?
  end
end
