# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'POST /user' do
    context '全てのパラメータが正当であるとき' do
      subject do
        post user_path, params: { name:, email:, password: Faker::Internet.password(min_length: 16) }
        response
      end

      let(:name) { Faker::Name.name }
      let(:email) { Faker::Internet.email }

      it { is_expected.to have_http_status :created }
      it { is_expected.to have_attributes media_type: 'application/json' }
      it { expect { subject }.to change(User, :count).by 1 }

      it '作成したユーザのメタデータをレスポンスボディに含む' do
        expect(subject.parsed_body).to include(
          {
            'id'         => anything,
            'name'       => name,
            'email'      => email,
            'created_at' => anything,
            'updated_at' => anything
          }
        )
      end
    end

    context 'パラメータが不正であるとき' do
      subject do
        post user_path, params: {
          name:     'a' * 65,
          email:    'foo.bar',
          password: 'password'
        }
        response
      end

      it { is_expected.to have_http_status :unprocessable_entity }
      it { is_expected.to have_attributes media_type: 'application/problem+json' }
      it { expect { subject }.not_to change(User, :count) }

      it 'レスポンスボディに適切なエラー内容が含まれている' do
        expect(subject.parsed_body).to include(
          {
            'status' => 422,
            'title'  => 'Unprocessable Entity',
            'errors' => [
              { 'name' => 'name', 'reason' => anything },
              { 'name' => 'email', 'reason' => anything },
              { 'name' => 'password', 'reason' => anything }
            ]
          }
        )
      end
    end
  end
end
