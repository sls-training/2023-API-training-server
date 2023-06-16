# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { described_class.new name:, email:, password: }

  let(:name) { 'foobar' }
  let(:email) { 'foobar@foo.bar' }
  let(:password) { 'a_little_bit_long_password' }

  context '値が全て適切であるとき' do
    it { is_expected.to be_valid }
  end

  describe '.name' do
    context 'nilのとき' do
      let(:name) { nil }

      it { is_expected.to be_invalid }
    end

    context '空文字列のとき' do
      let(:name) { '' }

      it { is_expected.to be_invalid }
    end

    context '文字列長が最短のとき' do
      let(:name) { 'a' }

      it { is_expected.to be_valid }
    end

    context '文字列長が最長のとき' do
      let(:name) { 'a' * 64 }

      it { is_expected.to be_valid }
    end

    context '文字列長が長すぎるとき' do
      let(:name) { 'a' * 65 }

      it { is_expected.to be_invalid }
    end

    context 'スペースのみで構成されているとき' do
      let(:name) { ' ' }

      it { is_expected.to be_invalid }
    end
  end

  describe '.email' do
    context 'nilのとき' do
      let(:email) { nil }

      it { is_expected.to be_invalid }
    end

    context '空文字列のとき' do
      let(:email) { '' }

      it { is_expected.to be_invalid }
    end

    context '正しいフォーマットのとき' do
      let(:email) { Faker::Internet.email }

      it { is_expected.to be_valid }
    end

    context '不正なフォーマットのとき' do
      it '検証に失敗する' do
        invalid_addresses = %w[
          user@example,com user_at_foo.org user.name@example.
          foo@bar_baz.com foo@bar+baz.com foo@bar..com
        ]

        invalid_addresses.each do |invalid_address|
          user.email = invalid_address
          expect(user).to be_invalid
        end
      end
    end

    context '同じメールアドレスのユーザが存在する場合' do
      before do
        described_class.create! name: Faker::Name.name, email:,
                                password: Faker::Internet.password(min_length: 16)
      end

      it { is_expected.to be_invalid }
    end

    context '大文字小文字違いのメールアドレスを持つユーザが存在する場合' do
      before do
        described_class.create! name: Faker::Name.name, email: email.upcase,
                                password: Faker::Internet.password(min_length: 16)
      end

      it { is_expected.to be_invalid }
    end
  end

  describe '.password' do
    context '空文字のとき' do
      let(:password) { '' }

      it { is_expected.to be_invalid }
    end

    context 'nilのとき' do
      let(:password) { nil }

      it { is_expected.to be_invalid }
    end

    context 'スペースのみで構成される場合' do
      let(:password) { ' ' * 16 }

      it { is_expected.to be_invalid }
    end

    context '文字列長が短すぎるとき' do
      let(:password) { 'a' * 15 }

      it { is_expected.to be_invalid }
    end

    context '文字列長が最短のとき' do
      let(:password) { 'a' * 16 }

      it { is_expected.to be_valid }
    end

    context '文字列長が最長のとき' do
      let(:password) { 'a' * 128 }

      it { is_expected.to be_valid }
    end

    context '文字列長が長すぎるとき' do
      let(:password) { 'a' * 129 }

      it { is_expected.to be_invalid }
    end
  end

  describe '.access_tokens' do
    context 'ユーザを削除したとき' do
      let!(:user) { FactoryBot.create :user, :with_access_tokens }

      it '発行されたアクセストークンも削除する' do
        expect { user.destroy! }.to change(AccessToken, :count).by(-1)
      end
    end
  end

  describe '#access_tokens' do
    describe '#build' do
      context 'デフォルト値で実行した場合' do
        it '作成されたアクセストークンは有効である' do
          expect(user.access_tokens.build).to be_valid
        end
      end
    end
  end
end
