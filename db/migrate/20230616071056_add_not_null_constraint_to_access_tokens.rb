class AddNotNullConstraintToAccessTokens < ActiveRecord::Migration[7.0]
  def change
    change_column_null :access_tokens, :token, false
    change_column_null :access_tokens, :scope, false
    change_column_null :access_tokens, :expires_in, false
  end
end
