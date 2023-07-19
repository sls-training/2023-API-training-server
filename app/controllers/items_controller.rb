# frozen_string_literal: true

class ItemsController < ApplicationController
  include Authorization

  def index
    files = current_user.files
              .joins(:file_blob)
              .order(index_orderby_param => index_order_param)
              .page(index_page_param)
              .per(index_per_param)

    render json: ItemResource.new(files).serialize(root_key: :files)
  end

  def create
    file = current_user.files.build file_params

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

  def index_page_param
    params[:page]
  end

  def index_per_param
    params[:per]
  end

  def index_orderby_param
    valid_orderbys = %i[id name description size created_at updated_at]
    orderby = params[:orderby]&.to_sym

    if orderby.in? valid_orderbys
      orderby == :size ? 'active_storage_blobs.byte_size' : orderby
    else
      :created_at
    end
  end

  def index_order_param
    params.fetch(:order, 'asc') == 'desc' ? :desc : :asc
  end
end
