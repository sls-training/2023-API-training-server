# frozen_string_literal: true

class AccessTokensController < ApplicationController
  before_action :validate_required_params
  before_action :validate_grant_type

  def post
    render problem: { error: 'invalid_grant' }, status: :bad_request and return if current_user.nil?

    access_token = current_user.access_tokens.build access_token_params

    if access_token.save
      set_disble_caching_headers

      render json: AccessTokenResource.new(access_token)
    elsif access_token.errors.key? :scope
      render problem: { error: 'invalid_scope' }, status: :bad_request
    else
      render problem: { errors: [{ name: 'access_token', reason: 'can not be created successfully' }] },
             status:  :internal_server_error
    end
  end

  private

  def validate_required_params
    render problem: { error: 'invalid_request' }, status: :bad_request unless contains_required_params?
  end

  def validate_grant_type
    render problem: { error: 'unsupported_grant_type' }, status: :bad_request unless supported_grant_type?
  end

  def current_user
    @current_user ||= User.find_by(email: params[:username])&.authenticate params[:password]
  end

  def access_token_params
    params.permit :scope
  end

  def contains_required_params?
    params.keys.to_set.superset? %w[grant_type username password].to_set
  end

  def supported_grant_type?
    params[:grant_type] == 'password'
  end

  def set_disble_caching_headers
    response.set_header 'Cache-Control', 'no-store'
    response.set_header 'Pragma', 'no-cache'
  end
end
