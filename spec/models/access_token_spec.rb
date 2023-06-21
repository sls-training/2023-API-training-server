# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessToken, type: :model do
  let(:user) { FactoryBot.create :user }

  describe '.new' do
    context 'ユーザのみを指定するとき' do
      subject { described_class.new user: }

      it { is_expected.to be_valid }
      it { is_expected.to have_attributes scope: 'READ WRITE' }
      it { is_expected.to have_attributes expires_in: 1.hour }
      it { is_expected.not_to be_revoked }
    end

    context '引数なしのとき' do
      subject { described_class.new }

      it { is_expected.to be_invalid }
    end
  end

  describe '#valid?' do
    describe 'token' do
      subject { access_token.valid? }

      let(:access_token) { described_class.new token:, user: }

      context 'Bearerトークンとして無効な文字列の場合' do
        let(:token) { "#{'a' * 15}@" }

        it { is_expected.to be_falsey }
      end

      context 'Bearerトークンとして有効な文字列の場合' do
        # パディングを除いてトークン文字列として有効な文字を全て含んだ文字列
        let(:token) { "#{(('a'..'z').to_a + ('A'..'Z').to_a + (1..9).to_a).join}-._~+/" }

        it { is_expected.to be_truthy }
      end

      context '重複しているとき' do
        let(:token) { 'a' * 16 }

        before do
          FactoryBot.create :access_token, token:
        end

        it { is_expected.to be_falsey }
      end
    end

    describe 'scope' do
      subject { access_token.valid? }

      let(:access_token) { described_class.new scope:, user: }

      context 'READのとき' do
        let(:scope) { 'READ' }

        it { is_expected.to be_truthy }
      end

      context 'WRITEのとき' do
        let(:scope) { 'WRITE' }

        it { is_expected.to be_truthy }
      end

      context '正当な値がスペース区切りで連結しているとき' do
        let(:scope) { 'READ WRITE' }

        it { is_expected.to be_truthy }
      end

      context '値が整列されていないとき' do
        let(:scope) { 'WRITE READ' }

        it { is_expected.to be_truthy }
      end

      context '不正な値のとき' do
        let(:scope) { Faker::Lorem.characters }

        it { is_expected.to be_falsey }
      end

      context '一部に正規のスコープの値を含んでいるとき' do
        let(:scope) { 'REWRITE' }

        it { is_expected.to be_falsey }
      end

      context 'スペース区切りになっていないとき' do
        let(:scope) { 'READ READWRITE' }

        it { is_expected.to be_falsey }
      end
    end

    describe 'expires_in' do
      subject { access_token.valid? }

      let(:access_token) { described_class.new expires_in:, user: }

      context '0以上の値のとき' do
        let(:expires_in) { 0 }

        it { is_expected.to be_truthy }
      end

      context '0未満の値のとき' do
        let(:expires_in) { -1 }

        it { is_expected.to be_falsey }
      end
    end
  end

  describe '#expired?' do
    subject { access_token.expired? }

    let(:access_token) { described_class.new user: }

    context '失効日時が未来のとき' do
      before do
        access_token.save!
      end

      it { is_expected.to be_falsey }
    end

    context '失効日時が過去のとき' do
      before do
        travel_to Date.current.yesterday do
          access_token.save!
        end
      end

      it { is_expected.to be_truthy }
    end

    context '永続化されていないとき' do
      it { expect { subject }.to raise_error RuntimeError }
    end
  end

  describe '#revoked?' do
    subject { access_token.revoked? }

    let(:access_token) { described_class.new revoked_at:, user: }

    context '無効化されているとき' do
      let(:revoked_at) { Time.current }

      it { is_expected.to be_truthy }
    end

    context '無効化されていないとき' do
      let(:revoked_at) { nil }

      it { is_expected.to be_falsey }
    end
  end

  describe '#revoke' do
    subject { access_token.revoke }

    let(:access_token) { described_class.new user: }

    context '無効化されているとき' do
      before do
        access_token.revoke
      end

      it 'revoked_atを更新しない' do
        expect { subject }.not_to change(access_token, :revoked_at)
      end
    end

    context '無効化されていないとき' do
      before do
        travel_to Time.current
      end

      it 'revoked_atに無効化日時を設定する' do
        expect { subject }.to change(access_token, :revoked_at).from(nil).to(Time.current)
      end
    end
  end
end
