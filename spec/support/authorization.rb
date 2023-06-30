# frozen_string_literal: true

RSpec.shared_examples 'Authorize using Bearer token with Resource Owner Password Credentials Grant of OAuth 2.0' do
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

  context 'アクセストークンが有効でないとき' do
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
