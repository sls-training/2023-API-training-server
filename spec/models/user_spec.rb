# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) do
    described_class.new name: 'foobar', email: 'foobar@foo.bar', password: 'a_little_bit_long_password',
                        password_confirmation: 'a_little_bit_long_password'
  end

  it { is_expected.to be_valid }

  context '名前がnilのとき' do
    before do
      user.name = nil
    end

    it { is_expected.to be_invalid }
  end

  context '名前が空文字列のとき' do
    before do
      user.name = ''
    end

    it { is_expected.to be_invalid }
  end

  context '名前の文字数が最小のとき' do
    before do
      user.name = 'a'
    end

    it { is_expected.to be_valid }
  end

  context '名前の文字数が最長のとき' do
    before do
      user.name = 'a' * 64
    end

    it { is_expected.to be_valid }
  end

  context '名前が長すぎるとき' do
    before do
      user.name = 'a' * 65
    end

    it { is_expected.to be_invalid }
  end

  context '名前がスペースのみで構成されているとき' do
    before do
      user.name = ' '
    end

    it { is_expected.to be_invalid }
  end

  context 'メールアドレスがnilのとき' do
    before do
      user.email = nil
    end

    it { is_expected.to be_invalid }
  end

  context 'メールアドレスが空文字列のとき' do
    before do
      user.email = ''
    end

    it { is_expected.to be_invalid }
  end

  it '正しいフォーマットのメールアドレスを許容する' do
    10.times do
      user.email = Faker::Internet.email
      expect(user).to be_valid
    end
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
    before do
      user.password = user.password_confirmation = ''
    end

    it { is_expected.to be_invalid }

    it 'DBへの保存に失敗する' do
      expect(user.save).not_to be_truthy
    end
  end

  context 'パスワードがnilのとき' do
    before do
      user.password = user.password_confirmation = nil
    end

    it { is_expected.to be_invalid }
  end

  context 'パスワードがスペースのみで構成される場合' do
    before do
      user.password = user.password_confirmation = ' ' * 16
    end

    it { is_expected.to be_invalid }
  end

  context 'パスワードが短すぎるとき' do
    before do
      user.password = user.password_confirmation = 'a' * 14
    end

    it { is_expected.to be_invalid }
  end

  context 'パスワード長が最短のとき' do
    before do
      user.password = user.password_confirmation = 'a' * 15
    end

    it { is_expected.to be_invalid }
  end

  context 'パスワードが最長のとき' do
    before do
      user.password = user.password_confirmation = 'a' * 128
    end

    it { is_expected.to be_invalid }
  end

  context 'パスワードが長すぎるとき' do
    before do
      user.password = user.password_confirmation = 'a' * 129
    end

    it { is_expected.to be_invalid }
  end

  context 'パスワード確認がnilのとき' do
    before do
      user.password_confirmation = nil
    end

    it { is_expected.to be_invalid }
  end
end
