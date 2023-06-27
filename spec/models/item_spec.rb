# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Item, type: :model do
  let(:user) { FactoryBot.create :user }

  describe '#valid?' do
    subject { item.valid? }

    context 'パラメータが全て正当であるとき' do
      let(:item) { described_class.new name:, description:, file:, user: }
      let(:name) { 'foo.txt' }
      let(:description) { Faker::Lorem.characters }
      let(:file) { fixture_file_upload 'empty.txt' }

      it { is_expected.to be_truthy }
    end

    context 'ファイルが指定されていないとき' do
      let(:item) { described_class.new file:, user: }
      let(:file) { nil }

      it { is_expected.to be_falsey }
    end

    context '同名のファイルが存在するとき' do
      let(:item) { described_class.new file:, user: }
      let(:file) { fixture_file_upload 'empty.txt' }

      before do
        described_class.new(file:, user:).save
      end

      it { is_expected.to be_falsey }
    end

    context '名前を省略したとき' do
      let(:item) { described_class.new file:, user: }
      let(:file) { fixture_file_upload 'empty.txt' }

      it { is_expected.to be_truthy }

      it '保存されるファイルの名前をファイル名として設定する' do
        expect { subject }.to change(item, :name).from(nil).to file.original_filename
      end
    end

    context '別のユーザが同名のファイル名のファイルを所有しているとき' do
      let(:item) { described_class.new file:, user: }
      let(:file) { fixture_file_upload 'empty.txt' }
      let(:another_user) { FactoryBot.create :user }

      before do
        another_user.files.create file:
      end

      it { is_expected.to be_truthy }
    end

    context 'ファイルサイズが大きすぎるとき' do
      let(:item) { described_class.new file:, user: }
      let(:file) { fixture_file_upload 'too_big_file.txt' }

      it { is_expected.to be_falsey }
    end
  end
end
