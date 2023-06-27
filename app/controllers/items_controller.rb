# frozen_string_literal: true

class ItemsController < ApplicationController
  include ActionController::HttpAuthentication::Token

  before_action :set_token_string, :validate_authentication_header
  before_action :set_access_token, :authenticate_access_token
  before_action :authorize_access_token_as_readable, only: %i[index show]
  before_action :authorize_access_token_as_writable, only: %i[create update destroy]

  def create
    user = access_token.user
    file = user.files.build file_params

    if file.save
      render json: ItemResource.new(file), status: :created
    else
      render problem: ProblemDetails::ItemResource.new(file), status: :unprocessable_entity
    end
  end

  private

  def file_params
    params.permit :name, :description, :file
  end

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
