# frozen_string_literal: true

class ItemsController < ApplicationController
  include Authorization

  def create
    file = current_user.files.build file_params

    if file.save
      render json: ItemResource.new(file), status: :created
    else
      render problem: ProblemDetails::ItemResource.new(file), status: :unprocessable_entity
    end
  end

  private

  def current_user
    access_token.user
  end

  def file_params
    params.permit :name, :description, :file
  end
end
