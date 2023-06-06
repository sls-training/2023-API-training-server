# frozen_string_literal: true

class UsersController < ApplicationController
  def post
    begin
      user = User.new user_params
    rescue ActionController::ParameterMissing => e
      # TODO: 欠落している全てのパラメータに関するエラーを返す。
      #
      # 欠落パラメータが複数存在していても最初に見つかったもののみのエラーを返す。
      render problem: { errors: format_parameter_missing_error(e) }, status: :bad_request and return
    end

    if user.save
      render json: UserResource.new(user), status: :created
    else
      render problem: { errors: format_errors(user.errors) }, status: :unprocessable_entity
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

  # ActiveModel::Errors クラスのオブジェクトをエラーレスポンス用の形式に変換する。
  #
  # TODO: helper等に移動させる。
  def format_errors(errors)
    errors.messages.each.map do |name, reasons|
      reasons.map { |reason| { name:, reason: } }
    end.flatten
  end

  # ActionController::ParameterMissing クラスのオブジェクトをエラーレスポンス用の形式に変換する。
  #
  # TODO: helper等に移動させる。
  def format_parameter_missing_error(error)
    [{ name: error.param, reason: 'is missing or the value is empty' }]
  end
end
