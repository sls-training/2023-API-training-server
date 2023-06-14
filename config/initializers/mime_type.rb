# frozen_string_literal: true

# Railsの Problem Details 対応(といってもMIMEタイプの登録のみ)は、2023-06-07の時点でRails 7.1(未リリース)からのようだ。
# https://github.com/rails/rails/commit/0d3bc8ec673fcb799e6e1f522d9dbf011e2a367b
#
# これをしておかないと、レスポンスのMIMEタイプが application/problem+json だった場合、Request Specにおける
# response オブジェクトの #parsed_body がMIMEタイプの照会に失敗して単なる文字列を返してしまう。
Mime::Type.register 'application/json', :json, ['application/problem+json']
