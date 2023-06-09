# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { described_class.new name:, email:, password:, password_confirmation: }

  let(:name) { 'foobar' }
  let(:email) { 'foobar@foo.bar' }
  let(:password) { 'a_little_bit_long_password' }
  let(:password_confirmation) { password }

  it { is_expected.to be_valid }

  context '名前がnilのとき' do
    let(:name) { nil }

    it { is_expected.to be_invalid }
  end

  context '名前が空文字列のとき' do
    let(:name) { '' }

    it { is_expected.to be_invalid }
  end

  context '名前の文字数が最小のとき' do
    let(:name) { 'a' }

    it { is_expected.to be_valid }
  end

  context '名前の文字数が最長のとき' do
    let(:name) { 'a' * 64 }

    it { is_expected.to be_valid }
  end

  context '名前が長すぎるとき' do
    let(:name) { 'a' * 65 }

    it { is_expected.to be_invalid }
  end

  context '名前がスペースのみで構成されているとき' do
    let(:name) { ' ' }

    it { is_expected.to be_invalid }
  end

  context 'メールアドレスがnilのとき' do
    let(:email) { nil }

    it { is_expected.to be_invalid }
  end

  context 'メールアドレスが空文字列のとき' do
    let(:email) { '' }

    it { is_expected.to be_invalid }
  end

  context 'メールアドレスが正しいフォーマットのとき' do
    let(:email) { Faker::Internet.email }

    it { is_expected.to be_valid }
  end

  it '不正なフォーマットのメールアドレスを拒否する' do
    invalid_addresses = %w[
      user@example,com user_at_foo.org user.name@example.
      foo@bar_baz.com foo@bar+baz.com foo@bar..com
    ]

    invalid_addresses.each do |invalid_address|
      user.email = invalid_address
      expect(user).not_to be_valid
    end
  end

  context '同じメールアドレスのユーザが存在する場合' do
    before do
      user.dup.save!
    end

    it { is_expected.to be_invalid }
  end

  context '大文字小文字違いのメールアドレスを持つユーザが存在する場合' do
    before do
      another_user = user.dup
      another_user.email = user.email.upcase
      another_user.save!
    end

    it { is_expected.to be_invalid }
  end

  context 'パスワードが空文字のとき' do
    let(:password) { '' }

    it { is_expected.to be_invalid }

    it 'DBへの保存に失敗する' do
      expect(user.save).not_to be_truthy
    end
  end

  context 'パスワードがnilのとき' do
    let(:password) { nil }

    it { is_expected.to be_invalid }
  end

  context 'パスワードがスペースのみで構成される場合' do
    let(:password) { ' ' * 16 }

    it { is_expected.to be_invalid }
  end

  context 'パスワードが短すぎるとき' do
    let(:password) { 'a' * 14 }

    it { is_expected.to be_invalid }
  end

  context 'パスワード長が最短のとき' do
    let(:password) { 'a' * 15 }

    it { is_expected.to be_invalid }
  end

  context 'パスワードが最長のとき' do
    let(:password) { 'a' * 128 }

    it { is_expected.to be_invalid }
  end

  context 'パスワードが長すぎるとき' do
    let(:password) { 'a' * 129 }

    it { is_expected.to be_invalid }
  end

  context 'パスワード確認がnilのとき' do
    let(:password_confirmation) { nil }

    it { is_expected.to be_invalid }
  end
end
