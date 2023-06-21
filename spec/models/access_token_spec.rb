# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessToken, type: :model do
  subject { described_class.new user: }

  let(:user) { FactoryBot.create :user }

  describe '.new' do
    context 'ユーザを指定するとき' do
      subject { described_class.new user: }

      it { is_expected.to be_valid }
    end
  end

  describe '#valid?' do
    describe 'token' do
      subject { described_class.new token:, user: }

      context 'nilのとき' do
        let(:token) { nil }

        it { is_expected.to be_invalid }
      end

      context '空文字列のとき' do
        let(:token) { '' }

        it { is_expected.to be_invalid }
      end

      context '空白文字列のとき' do
        let(:token) { ' ' }

        it { is_expected.to be_invalid }
      end

      context '短すぎるとき' do
        let(:token) { 'a' * 15 }

        it { is_expected.to be_invalid }
      end

      context 'パディング以外の文字列が短すぎるとき' do
        let(:token) { "#{'a' * 15}=" }

        it { is_expected.to be_invalid }
      end

      context '許可されていない文字を含んでいるとき' do
        let(:token) { "#{'a' * 15}@" }

        it { is_expected.to be_invalid }
      end

      context '重複しているとき' do
        let(:token) { 'a' * 16 }

        before do
          FactoryBot.create :access_token, token:
        end

        it { is_expected.to be_invalid }
      end

      context 'Bearerトークンとして有効な文字列の場合' do
        # パディングを除いてトークン文字列として有効な文字を全て含んだ文字列
        let(:token) { "#{(('a'..'z').to_a + ('A'..'Z').to_a + (1..9).to_a).join}-._~+/" }

        it { is_expected.to be_valid }
      end
    end

    describe 'scope' do
      subject { described_class.new scope:, user: }

      context 'nilのとき' do
        let(:scope) { nil }

        it { is_expected.to be_invalid }
      end

      context '空文字列のとき' do
        let(:scope) { '' }

        it { is_expected.to be_invalid }
      end

      context '空白文字列のとき' do
        let(:scope) { ' ' }

        it { is_expected.to be_invalid }
      end

      context '適当な値のとき' do
        let(:scope) { Faker::Lorem.characters }

        it { is_expected.to be_invalid }
      end

      context '一部に正規のスコープの値を含んでいるとき' do
        let(:scope) { 'REWRITE' }

        it { is_expected.to be_invalid }
      end

      context 'スペース区切りになっていないとき' do
        let(:scope) { 'READ READWRITE' }

        it { is_expected.to be_invalid }
      end
    end

    describe 'expires_in' do
      subject { described_class.new expires_in:, user: }

      context 'nilのとき' do
        let(:expires_in) { nil }

        it { is_expected.to be_invalid }
      end

      context '0のとき' do
        let(:expires_in) { 0 }

        it { is_expected.to be_valid }
      end

      context '-1のとき' do
        let(:expires_in) { -1 }

        it { is_expected.to be_invalid }
      end
    end

    describe 'revoked_at' do
      subject { described_class.new revoked_at:, user: }

      context 'nilのとき' do
        let(:revoked_at) { nil }

        it { is_expected.to be_valid }
      end
    end

    describe 'user' do
      subject { described_class.new user: }

      context 'nilのとき' do
        let(:user) { nil }

        it { is_expected.to be_invalid }
      end
    end
  end

  describe '#expired?' do
    context '失効日時が未来のとき' do
      before do
        subject.save!
      end

      it { is_expected.not_to be_expired }
    end

    context '失効日時が過去のとき' do
      before do
        travel_to Date.current.yesterday do
          subject.save!
        end
      end

      it { is_expected.to be_expired }
    end
  end

  describe '#revoked?' do
    subject { described_class.new revoked_at:, user: }

    context '無効化されていたら' do
      let(:revoked_at) { Time.current }

      it { is_expected.to be_revoked }
    end

    context '無効化されていなかったら' do
      let(:revoked_at) { nil }

      it { is_expected.not_to be_revoked }
    end
  end

  describe '#revoke' do
    context '無効化されていたら' do
      before do
        subject.revoke
      end

      it 'revoked_atを更新しない' do
        expect { subject.revoke }.not_to change(subject, :revoked_at)
      end
    end

    context '無効化されていなかったら' do
      before do
        subject.revoke
      end

      it 'revoked_atに無効化日時を設定する' do
        expect(subject.revoked_at).not_to be_nil
      end
    end
  end
end
