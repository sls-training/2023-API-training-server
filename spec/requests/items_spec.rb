# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Items', type: :request do
  describe 'POST /files' do
    let(:user) { FactoryBot.create :user }
    let(:access_token) { user.access_tokens.create! scope: 'READ WRITE' }

    context '認証に成功したとき' do
      context 'パラメータが正当なとき' do
        subject do
          post files_path, params:  { name:, description:, file: },
                           headers: { Authorization: "Bearer #{access_token.token}" }
          response
        end

        let(:name) { 'file.txt' }
        let(:description) { 'This is a sample file.' }
        let(:file) { fixture_file_upload 'empty.txt' }

        it { is_expected.to have_http_status :created }
        it { is_expected.to have_attributes media_type: 'application/json' }

        it 'アップロードしたファイルのメタデータがボディにJSONとして格納される' do
          expect(subject.parsed_body).to include(
            'id'          => user.files.last.id,
            'name'        => name,
            'description' => description,
            'size'        => 0,
            'created_at'  => user.files.last.created_at.iso8601,
            'updated_at'  => user.files.last.updated_at.iso8601
          )
        end
      end

      context 'パラメータが不正なとき' do
        subject do
          post files_path, params: {}, headers: { Authorization: "Bearer #{access_token.token}" }
          response
        end

        it { is_expected.to have_http_status :unprocessable_entity }
        it { is_expected.to have_attributes media_type: 'application/problem+json' }

        it '発生したエラーに関する情報がProblem Detailsに対応したJSON形式でボディに格納される' do
          expect(subject.parsed_body).to include(
            'status' => 422,
            'title'  => 'Unprocessable Entity',
            'errors' => [
              { 'name' => 'name', 'reason' => anything },
              { 'name' => 'file', 'reason' => anything }
            ]
          )
        end
      end
    end

    context '認証に必要なパラメータが欠落しているとき' do
      subject do
        post files_path
        response
      end

      it { is_expected.to have_http_status :bad_request }
      it { is_expected.to have_attributes media_type: 'application/problem+json' }

      it '発生したエラーに関する情報がProblem Detailsに対応したJSON形式でボディに格納される' do
        expect(subject.parsed_body).to include(
          'status' => 400,
          'title'  => 'Bad Request',
          'error'  => 'invalid_request'
        )
      end
    end

    context 'アクセストークンが存在しないとき' do
      subject do
        post files_path, params: {}, headers: { Authorization: "Bearer #{Faker::Alphanumeric.alphanumeric}" }
        response
      end

      it { is_expected.to have_http_status :unauthorized }
      it { is_expected.to have_attributes media_type: 'application/problem+json' }

      it '発生したエラーに関する情報がProblem Detailsに対応したJSON形式でボディに格納される' do
        expect(subject.parsed_body).to include(
          'status' => 401,
          'title'  => 'Unauthorized',
          'error'  => 'invalid_token'
        )
      end
    end

    context 'アクセストークンが無効化されているとき' do
      subject do
        post files_path, params: {}, headers: { Authorization: "Bearer #{access_token.token}" }
        response
      end

      before do
        access_token.revoke
      end

      it { is_expected.to have_http_status :unauthorized }
      it { is_expected.to have_attributes media_type: 'application/problem+json' }

      it '発生したエラーに関する情報がProblem Detailsに対応したJSON形式でボディに格納される' do
        expect(subject.parsed_body).to include(
          'status' => 401,
          'title'  => 'Unauthorized',
          'error'  => 'invalid_token'
        )
      end
    end

    context 'アクセストークンが失効しているとき' do
      subject do
        post files_path, params: {}, headers: { Authorization: "Bearer #{access_token.token}" }
        response
      end

      before do
        travel_to access_token.created_at + access_token.expires_in + 1
      end

      it { is_expected.to have_http_status :unauthorized }
      it { is_expected.to have_attributes media_type: 'application/problem+json' }

      it '発生したエラーに関する情報がProblem Detailsに対応したJSON形式でボディに格納される' do
        expect(subject.parsed_body).to include(
          'status' => 401,
          'title'  => 'Unauthorized',
          'error'  => 'invalid_token'
        )
      end
    end

    context 'アクセストークンの権限が不足しているとき' do
      subject do
        post files_path, params: {}, headers: { Authorization: "Bearer #{access_token.token}" }
        response
      end

      let(:access_token) { user.access_tokens.create! scope: 'READ' }

      it { is_expected.to have_http_status :forbidden }
      it { is_expected.to have_attributes media_type: 'application/problem+json' }

      it '発生したエラーに関する情報がProblem Detailsに対応したJSON形式でボディに格納される' do
        expect(subject.parsed_body).to include(
          'status' => 403,
          'title'  => 'Forbidden',
          'error'  => 'insufficient_scope',
          'scope'  => 'WRITE'
        )
      end
    end
  end
end
