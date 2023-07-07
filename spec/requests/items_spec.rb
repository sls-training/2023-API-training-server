# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Items', type: :request do
  describe 'GET /files' do
    let(:user) { FactoryBot.create :user }
    let(:access_token) { user.access_tokens.create! scope: 'READ' }

    context '認証に成功したとき' do
      let(:file) { fixture_file_upload 'empty.txt' }

      context 'パラメータがないとき' do
        subject do
          get files_path, headers: { Authorization: "Bearer #{access_token.token}" }
          response
        end

        before do
          FactoryBot.create_list :item, 21, file:, user:
        end

        it { is_expected.to have_http_status :success }
        it { is_expected.to have_attributes media_type: 'application/json' }

        it 'filesキーにアップロード済みファイル一覧が格納される' do
          expect(subject.parsed_body).to include(
            'files' => include(
              include(
                'id'          => anything,
                'name'        => anything,
                'description' => anything,
                'size'        => anything,
                'created_at'  => anything,
                'updated_at'  => anything
              )
            )
          )
        end

        it 'ページ番号1に含まれるファイル一覧が含まれる' do
          first_page_file_ids = user.files.sort_by(&:created_at).take(20).map(&:id)

          expect(subject.parsed_body['files'].map { |h| h['id'] }).to match_array first_page_file_ids
        end

        it '含まれるファイル一覧の総数は20である' do
          expect(subject.parsed_body['files']).to have_attributes(size: 20)
        end

        it 'created_atの昇順にソートされている' do
          sorted_file_ids = user.files.sort_by(&:created_at).take(20).map(&:id)

          expect(subject.parsed_body['files'].map { |h| h['id'] }).to eq sorted_file_ids
        end
      end

      context 'パラメータにpageが含まれているとき' do
        subject do
          get files_path, params: { page: }, headers: { Authorization: "Bearer #{access_token.token}" }
          response
        end

        before do
          FactoryBot.create_list :item, 21, file:, user:
        end

        context '1のとき' do
          let(:page) { 1 }

          it { is_expected.to have_http_status :success }
          it { is_expected.to have_attributes media_type: 'application/json' }

          it '1ページ目のファイル一覧を取得する。' do
            first_page_file_ids = user.files.sort_by(&:created_at).take(20).map { |h| h['id'] }

            expect(subject.parsed_body['files'].map { |h| h['id'] }).to match_array first_page_file_ids
          end
        end

        context '2のとき' do
          let(:page) { 2 }

          it { is_expected.to have_http_status :success }
          it { is_expected.to have_attributes media_type: 'application/json' }

          it '2ページ目のファイル一覧を取得する。' do
            second_page_file_ids = user.files.sort_by(&:created_at).drop(20).take(20).map { |h| h['id'] }

            expect(subject.parsed_body['files'].map { |h| h['id'] }).to match_array second_page_file_ids
          end
        end

        context '不正な値のとき' do
          let(:page) { 'foo' }

          it { is_expected.to have_http_status :success }
          it { is_expected.to have_attributes media_type: 'application/json' }

          it '1ページ目のファイル一覧を取得する。' do
            first_page_file_ids = user.files.sort_by(&:created_at).take(20).map { |h| h['id'] }

            expect(subject.parsed_body['files'].map { |h| h['id'] }).to match_array first_page_file_ids
          end
        end
      end

      context 'パラメータにperが含まれているとき' do
        subject do
          get files_path, params: { per: }, headers: { Authorization: "Bearer #{access_token.token}" }
          response
        end

        before do
          FactoryBot.create_list :item, 20, file:, user:
        end

        context '10のとき' do
          let(:per) { 10 }

          it { is_expected.to have_http_status :success }
          it { is_expected.to have_attributes media_type: 'application/json' }

          it 'ファイル一覧に含まれるファイルの件数は10である。' do
            expect(subject.parsed_body['files']).to have_attributes(size: 10)
          end
        end

        context '20のとき' do
          let(:per) { 20 }

          it { is_expected.to have_http_status :success }
          it { is_expected.to have_attributes media_type: 'application/json' }

          it 'ファイル一覧に含まれるファイルの件数は20である。' do
            expect(subject.parsed_body['files']).to have_attributes(size: 20)
          end
        end

        context '不正な値のとき' do
          let(:per) { 'foo' }

          it { is_expected.to have_http_status :success }
          it { is_expected.to have_attributes media_type: 'application/json' }

          it 'ファイル一覧に含まれるファイルの件数は20である。' do
            expect(subject.parsed_body['files']).to have_attributes(size: 20)
          end
        end
      end

      context 'パラメータにorderが含まれているとき' do
        subject do
          get files_path, params: { order: }, headers: { Authorization: "Bearer #{access_token.token}" }
          response
        end

        before do
          FactoryBot.create_list :item, 20, file:, user:
        end

        context 'ascのとき' do
          let(:order) { 'asc' }

          it { is_expected.to have_http_status :success }
          it { is_expected.to have_attributes media_type: 'application/json' }

          it 'ファイル一覧が昇順にソートされている' do
            sorted_file_ids = user.files.sort_by(&:created_at).map(&:id)

            expect(subject.parsed_body['files'].map { |h| h['id'] }).to eq sorted_file_ids
          end
        end

        context 'descのとき' do
          let(:order) { 'desc' }

          it { is_expected.to have_http_status :success }
          it { is_expected.to have_attributes media_type: 'application/json' }

          it 'ファイル一覧が降順にソートされている' do
            sorted_file_ids = user.files.sort_by(&:created_at).map(&:id).reverse

            expect(subject.parsed_body['files'].map { |h| h['id'] }).to eq sorted_file_ids
          end
        end

        context '不正な値のとき' do
          let(:order) { 'foo' }

          it { is_expected.to have_http_status :success }
          it { is_expected.to have_attributes media_type: 'application/json' }

          it 'ファイル一覧が昇順にソートされている' do
            sorted_file_ids = user.files.sort_by(&:created_at).map(&:id)

            expect(subject.parsed_body['files'].map { |h| h['id'] }).to eq sorted_file_ids
          end
        end
      end

      context 'パラメータにorderbyが含まれているとき' do
        subject do
          get files_path, params: { orderby: }, headers: { Authorization: "Bearer #{access_token.token}" }
          response
        end

        context 'idのとき' do
          let(:orderby) { :id }

          before do
            FactoryBot.create_list :item, 20, file:, user:
          end

          it { is_expected.to have_http_status :success }
          it { is_expected.to have_attributes media_type: 'application/json' }

          it 'ID順にソートされている' do
            sorted_file_ids = user.files.sort_by(&:id).map(&:id)

            expect(subject.parsed_body['files'].map { |h| h['id'] }).to eq sorted_file_ids
          end
        end

        context 'nameのとき' do
          let(:orderby) { :name }

          before do
            FactoryBot.create_list :item, 20, file:, user:
          end

          it { is_expected.to have_http_status :success }
          it { is_expected.to have_attributes media_type: 'application/json' }

          it '名前順にソートされている' do
            sorted_file_ids = user.files.sort_by(&:name).map(&:id)

            expect(subject.parsed_body['files'].map { |h| h['id'] }).to eq sorted_file_ids
          end
        end

        context 'descriptionのとき' do
          let(:orderby) { :description }

          before do
            FactoryBot.build_list(:item, 20, file:, user:) do |item|
              item.description = Faker::Lorem.characters
              item.save!
            end
          end

          it { is_expected.to have_http_status :success }
          it { is_expected.to have_attributes media_type: 'application/json' }

          it '説明文をキーにしてソートされている' do
            sorted_file_ids = user.files.sort_by(&:description).map(&:id)

            expect(subject.parsed_body['files'].map { |h| h['id'] }).to eq sorted_file_ids
          end
        end

        context 'sizeのとき' do
          let(:orderby) { :size }

          before do
            FactoryBot.build_list(:item, 20, file:, user:).shuffle.each_with_index do |item, i|
              item.file.byte_size = i
              item.save!
            end
          end

          it { is_expected.to have_http_status :success }
          it { is_expected.to have_attributes media_type: 'application/json' }

          it 'ファイルサイズをキーにしてソートされている' do
            sorted_file_ids = user.files.sort_by { |item| item.file.byte_size }.map(&:id)

            expect(subject.parsed_body['files'].map { |h| h['id'] }).to eq sorted_file_ids
          end
        end

        context 'created_atのとき' do
          let(:orderby) { :created_at }

          before do
            FactoryBot.create_list :item, 20, file:, user:
          end

          it { is_expected.to have_http_status :success }
          it { is_expected.to have_attributes media_type: 'application/json' }

          it '作成日時をキーにしてソートされている' do
            sorted_file_ids = user.files.sort_by(&:created_at).map(&:id)

            expect(subject.parsed_body['files'].map { |h| h['id'] }).to eq sorted_file_ids
          end
        end

        context 'updated_atのとき' do
          let(:orderby) { :updated_at }

          before do
            FactoryBot.create_list(:item, 20, file:, user:).shuffle.each(&:touch)
          end

          it { is_expected.to have_http_status :success }
          it { is_expected.to have_attributes media_type: 'application/json' }

          it '更新日時をキーにしてソートされている' do
            sorted_file_ids = user.files.sort_by(&:updated_at).map(&:id)

            expect(subject.parsed_body['files'].map { |h| h['id'] }).to eq sorted_file_ids
          end
        end

        context '不正な値のとき' do
          let(:orderby) { :foo }

          before do
            FactoryBot.create_list :item, 20, file:, user:
          end

          it { is_expected.to have_http_status :success }
          it { is_expected.to have_attributes media_type: 'application/json' }

          it '作成日時をキーにしてソートされている' do
            sorted_file_ids = user.files.sort_by(&:created_at).map(&:id)

            expect(subject.parsed_body['files'].map { |h| h['id'] }).to eq sorted_file_ids
          end
        end
      end
    end

    context '認証に必要なパラメータが欠落しているとき' do
      subject do
        get files_path
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
        get files_path, params: {}, headers: { Authorization: "Bearer #{Faker::Alphanumeric.alphanumeric}" }
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
        get files_path, params: {}, headers: { Authorization: "Bearer #{access_token.token}" }
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
        get files_path, params: {}, headers: { Authorization: "Bearer #{access_token.token}" }
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
        get files_path, params: {}, headers: { Authorization: "Bearer #{access_token.token}" }
        response
      end

      let(:access_token) { user.access_tokens.create! scope: 'WRITE' }

      it { is_expected.to have_http_status :forbidden }
      it { is_expected.to have_attributes media_type: 'application/problem+json' }

      it '発生したエラーに関する情報がProblem Detailsに対応したJSON形式でボディに格納される' do
        expect(subject.parsed_body).to include(
          'status' => 403,
          'title'  => 'Forbidden',
          'error'  => 'insufficient_scope',
          'scope'  => 'READ'
        )
      end
    end
  end

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
        it { expect { subject }.to change(Item, :count).by 1 }

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
