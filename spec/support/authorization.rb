# frozen_string_literal: true

# 利用する場合は、リクエストの送り先と利用するアクセストークンを #let や #let! を使って、それぞれ request_path と access_token という名前で宣言しておく必要がある。
#
# it_behave_like 'OAuth 2.0のResource Owner Password Credentials Grantを利用したBearer Tokenによる認可を行う' do
#   let(:request_path) { '/path/to/resource' }
#   let(:access_token) { an_access_token }
# end
RSpec.shared_examples 'OAuth 2.0のResource Owner Password Credentials Grantを利用したBearer Tokenによる認可を行う' do
  context '認証に必要なパラメータが欠落しているとき' do
    subject do
      post request_path
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
      post request_path, params: {}, headers: { Authorization: "Bearer #{Faker::Alphanumeric.alphanumeric}" }
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
      post request_path, params: {}, headers: { Authorization: "Bearer #{access_token.token}" }
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
      post request_path, params: {}, headers: { Authorization: "Bearer #{access_token.token}" }
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
      post request_path, params: {}, headers: { Authorization: "Bearer #{access_token.token}" }
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
