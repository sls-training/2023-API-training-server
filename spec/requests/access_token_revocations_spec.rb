# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AccessTokenRevocations', type: :request do
  describe 'POST /signout' do
    let(:user) { FactoryBot.create :user }
    let(:access_token) { user.access_tokens.create! }

    context 'まだ無効化されていないアクセストークンを渡したとき' do
      subject do
        post signout_path, params: { token: access_token.token }
        response
      end

      it { is_expected.to have_http_status :success }

      it '渡されたトークンに対応するアクセストークンが無効化される' do
        expect { subject }.to change { access_token.reload.revoked? }.from(false).to true
      end
    end

    context 'すでに無効化されているアクセストークンを渡したとき' do
      subject do
        post signout_path, params: { token: access_token.token }
        response
      end

      before do
        access_token.revoke
      end

      it { is_expected.to have_http_status :success }

      it '渡されたトークンに対応するアクセストークンは無効化されたままである' do
        expect { subject }.not_to(change { access_token.reload.revoked? })
      end
    end

    context '存在しないアクセストークンを渡したとき' do
      subject do
        post signout_path, params: { token: Faker::String.random }
        response
      end

      it { is_expected.to have_http_status :bad_request }
      it { is_expected.to have_attributes media_type: 'application/problem+json' }

      it '発生したエラーに関する情報をProblem Details形式でボディにJSONとして含む' do
        expect(subject.parsed_body).to include(
          'status' => 400,
          'title'  => 'Bad Request',
          'error'  => 'invalid_request'
        )
      end
    end
  end
end
