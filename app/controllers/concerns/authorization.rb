# frozen_string_literal: true

module Authorization
  extend ActiveSupport::Concern

  include ActionController::HttpAuthentication::Token

  included do
    before_action :set_token_and_options, :validate_token_and_options
    before_action :authenticate_access_token
    before_action :require_authorized_as_readable, only: %i[index show]
    before_action :require_authorized_as_writable, only: %i[create update destroy]
  end

  private

  # NOTE: #token_and_options の仕様上、Authorizationヘッダのトークンタイプが Bearer だけでなく Token の場合も正当なフォーマットとして受理される。
  # ここではどうしてもどちらか一方のみを有効にしなければならないわけではないので、そのままにしておく。
  def set_token_and_options
    @token_string, @token_options = token_and_options request
  end

  def validate_token_and_options
    return unless @token_string.blank? || @token_options.present?

    render problem: { error: 'invalid_request' }, status: :bad_request
  end

  def access_token
    @access_token ||= AccessToken.find_by token: @token_string
  end

  def authenticate_access_token
    return unless access_token.nil? || access_token.revoked? || access_token.expired?

    render problem: { error: 'invalid_token' }, status: :unauthorized
  end

  def require_authorized_as(scope)
    return if access_token.authorized? scope

    render problem: { error: 'insufficient_scope', scope: }, status: :forbidden
  end

  def require_authorized_as_readable
    require_authorized_as 'READ'
  end

  def require_authorized_as_writable
    require_authorized_as 'WRITE'
  end

  def current_user
    access_token&.user
  end
end
