# frozen_string_literal: true

module Authorization
  extend ActiveSupport::Concern

  include ActionController::HttpAuthentication::Token

  included do
    before_action :set_token_string, :validate_authentication_header
    before_action :set_access_token, :authenticate_access_token
    before_action :authorize_access_token_as_readable, only: %i[index show]
    before_action :authorize_access_token_as_writable, only: %i[create update destroy]
  end

  private

  def token_string
    @token_string ||= nil
  end

  def set_token_string
    token, options = token_and_options request

    @token_string = token if token.present? && options.empty?
  end

  def validate_authentication_header
    render problem: { error: 'invalid_request' }, status: :bad_request if token_string.blank?
  end

  def access_token
    @access_token ||= nil
  end

  def set_access_token
    @access_token = AccessToken.find_by token: token_string
  end

  def authenticate_access_token
    return unless access_token.nil? || access_token.revoked? || access_token.expired?

    render problem: { error: 'invalid_token' }, status: :unauthorized
  end

  def authorize_access_token_as(scope)
    return if access_token.authorize? scope

    render problem: { error: 'insufficient_scope', scope: }, status: :forbidden
  end

  def authorize_access_token_as_readable
    authorize_access_token_as 'READ'
  end

  def authorize_access_token_as_writable
    authorize_access_token_as 'WRITE'
  end
end
