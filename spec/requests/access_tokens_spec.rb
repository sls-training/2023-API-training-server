# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AccessTokens', type: :request do
  describe 'POST /signin' do
    let(:user) { FactoryBot.create :user }
    let(:grant_type) { 'password' }
    let(:username) { user.email }
    let(:password) { user.password }

    context '正当なパラメータを渡したとき' do
      subject do
        post signin_path, params: { grant_type:, username:, password: }
        response
      end

      it { is_expected.to have_http_status :success }
      it { is_expected.to have_attributes media_type: 'application/json' }

      it '値がno-storeであるCache-Controlヘッダを含む' do
        expect(subject.get_header('Cache-Control')).to eq 'no-store'
      end

      it '値がno-cacheであるPragmaヘッダを含む' do
        expect(subject.get_header('Pragma')).to eq 'no-cache'
      end

      context 'パラメータにscopeが含まれていないとき' do
        it 'レスポンスボディに発行したアクセストークンとそのメタデータを含む' do
          expect(subject.parsed_body).to include(
            'access_token' => user.access_tokens.last.token,
            'token_type'   => 'bearer',
            'expires_in'   => 1.hour,
            'scope'        => 'READ WRITE'
          )
        end
      end

      context 'パラメータにscopeが含まれているとき' do
        subject do
          post signin_path, params: { grant_type:, username:, password:, scope: }
          response
        end

        let(:scope) { 'READ' }

        it 'リクエストしたscopeの値がレスポンスボディに含まれている' do
          expect(subject.parsed_body).to include(
            'access_token' => user.access_tokens.last.token,
            'token_type'   => 'bearer',
            'expires_in'   => 1.hour,
            'scope'        => scope
          )
        end
      end
    end

    context '必須パラメータが欠落していたとき' do
      subject do
        post signin_path, params: {}
        response
      end

      it { is_expected.to have_http_status :bad_request }
      it { is_expected.to have_attributes media_type: 'application/problem+json' }
      it { expect(subject.parsed_body).to include 'error' => 'invalid_request' }
    end

    context '不正な認証情報を渡したとき' do
      subject do
        post signin_path, params: { grant_type:, username:, password: }
        response
      end

      let(:username) { 'foo' }
      let(:password) { 'bar' }

      it { is_expected.to have_http_status :bad_request }
      it { is_expected.to have_attributes media_type: 'application/problem+json' }
      it { expect(subject.parsed_body).to include 'error' => 'invalid_grant' }
    end

    context 'サポートしていないgrant_typeを渡したとき' do
      subject do
        post signin_path, params: { grant_type:, username:, password: }
        response
      end

      let(:grant_type) { 'code' }

      it { is_expected.to have_http_status :bad_request }
      it { is_expected.to have_attributes media_type: 'application/problem+json' }
      it { expect(subject.parsed_body).to include 'error' => 'unsupported_grant_type' }
    end

    context '不正なscopeを渡したとき' do
      subject do
        post signin_path, params: { grant_type:, username:, password:, scope: }
        response
      end

      let(:scope) { 'foo' }

      it { is_expected.to have_http_status :bad_request }
      it { is_expected.to have_attributes media_type: 'application/problem+json' }
      it { expect(subject.parsed_body).to include 'error' => 'invalid_scope' }
    end
  end
end
