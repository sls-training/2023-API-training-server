# frozen_string_literal: true

class UsersController < ApplicationController
  def post
    user = User.new user_params

    if user.save
      render json: UserResource.new(user), status: :created
    else
      render problem: { errors: ActiveModel::ErrorsDecorator.new(user.errors).to_a }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:name, :email, :password)
  end
end
