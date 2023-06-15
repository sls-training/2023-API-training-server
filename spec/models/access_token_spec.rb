# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessToken, type: :model do
  subject { described_class.new token:, scope:, expires_in:, revoked_at:, user: }

  let(:token) { SecureRandom.base64 }
  let(:scope) { 'READ WRITE' }
  let(:expires_in) { 60 * 60 }
  let(:revoked_at) { nil }
  let(:user) { FactoryBot.create :user }

  context '値が全て適切であるとき' do
    it { is_expected.to be_valid }
  end

  describe '.token' do
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
      before do
        FactoryBot.create :access_token, token:
      end

      it { is_expected.to be_invalid }
    end
  end

  describe '.scope' do
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
  end

  describe '.expires_in' do
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

  describe '.revoked_at' do
    context 'nilのとき' do
      let(:revoked_at) { nil }

      it { is_expected.to be_valid }
    end
  end

  describe '.user' do
    context 'nilのとき' do
      let(:user) { nil }

      it { is_expected.to be_invalid }
    end
  end

  describe '#expires?' do
    context '失効日時が未来のとき' do
      before do
        subject.save!
      end

      it { is_expected.not_to be_expires }
    end

    context '失効日時が過去のとき' do
      before do
        subject.save!
      end

      it 'trueを返す' do
        travel_to Date.current.tomorrow do
          expect(subject).to be_expires
        end
      end
    end
  end

  describe '#revoked?' do
    context '失効されていたら' do
      let(:revoked_at) { Time.current }

      it { is_expected.to be_revoked }
    end

    context '失効されていなかったら' do
      it { is_expected.not_to be_revoked }
    end
  end

  describe '#revoke' do
    context '失効されていたら' do
      let(:revoked_at) { Time.current }

      it 'revoked_atを更新しない' do
        travel_to Time.current.tomorrow do
          subject.revoke
          expect(subject.revoked_at).to eq revoked_at
        end
      end
    end

    context '失効されていなかったら' do
      before do
        subject.revoke
      end

      it 'revoked_atに失効日時を設定する' do
        expect(subject.revoked_at).not_to be_nil
      end
    end
  end
end
