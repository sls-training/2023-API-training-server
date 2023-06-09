# frozen_string_literal: true

class UsersController < ApplicationController
  def post
    begin
      user = User.new user_params
    rescue ActionController::ParameterMissing => e
      # TODO: 欠落している全てのパラメータに関するエラーを返す。
      #
      # 欠落パラメータが複数存在していても最初に見つかったもののみのエラーを返す。
      render problem: { errors: ActionController::ParameterMissingDecorator.new(e).to_a },
             status:  :bad_request and return
    end

    if user.save
      render json: UserResource.new(user), status: :created
    else
      render problem: { errors: ActiveModel::ErrorsDecorator.new(user.errors).to_a }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    keys = %i[name email password]

    # #require に引数として配列を渡した場合、それぞれのキーに対応する値の array を返すため、 #permit のような
    # ActionController::Parameters クラスのメソッドをチェーンで呼ぶことができない。
    params.require(keys)
    params.permit(keys)
  end
end