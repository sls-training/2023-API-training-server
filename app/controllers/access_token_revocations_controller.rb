# frozen_string_literal: true

class AccessTokenRevocationsController < ApplicationController
  def create
    access_token = AccessToken.find_by token: params[:token]

    render problem: { error: 'invalid_request' }, status: :bad_request and return unless access_token

    access_token.revoke
    head :ok
  end
end
