# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'POST /user' do
    context '全てのパラメータが正当であるとき' do
      subject do
        post user_path, params: {
          name:     Faker::Name.name,
          email:    Faker::Internet.email,
          password: Faker::Internet.password(min_length: 16)
        }
        response
      end

      it { is_expected.to have_http_status :created }
      it { is_expected.to have_attributes media_type: 'application/json' }
      it { expect { subject }.to change(User, :count).by 1 }

      it '作成したユーザのメタデータをレスポンスボディに含む' do
        json = subject.parsed_body
        user = User.first

        expect(json).to include(
          {
            'id'         => user.id,
            'name'       => user.name,
            'email'      => user.email,
            'created_at' => user.created_at.iso8601,
            'updated_at' => user.updated_at.iso8601
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
