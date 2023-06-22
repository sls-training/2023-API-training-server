# frozen_string_literal: true

class AccessTokenResource
  include Alba::Resource

  attributes :expires_in, :scope

  attribute :access_token, &:token
  attribute(:token_type) { 'bearer' }
end
