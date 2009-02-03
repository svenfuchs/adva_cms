require 'authentication/hash_helper'

module Authentication
  # Implements a token with expiration that is stored on the model
  # being authenticated. This is designed to implement the common
  # practice of having a token in the URL that will automatically
  # authenticate the user. 
  #
  # The model should implement the fields "token_key" (a 40 character
  # field) and "token_expiration" (a datetime field). If they are not
  # implemented this class cannot authenticate or assign tokens.
  #
  # This token module is called SingleToken because it only can
  # store one token. If another token is assigned the first is lost
  # and will not authenticate the user anymore. For common needs such
  # as forgot my password and account restoration this is fine.
  #
  # This token does NOT honor the verified_at field that the
  # Authentication::SaltedHash module and Authentication::RememberMe
  # module do since this token may be used to actually implement the
  # email verification.
  class SingleToken
    include HashHelper

    # Will test to see if the given key is valid for the given user
    def authenticate(user, key)
      return false unless valid_model? user
      return false unless key.to_s.length == 40

      conditions = [
        'id = ? AND token_key = ? AND (token_expiration >= ? OR token_expiration IS NULL)',
        user.id, hash_string(key), Time.zone.now
      ]
      0 < user.class.count(:conditions => conditions)
    end

    # Will create a new token for the given user with the given expiration
    def assign_token(user, name, expire)
      return nil unless valid_model? user

      user.token_expiration = expire
      token = hash_string "token-#{Time.zone.now}"
      user.token_key = hash_string token
      token
    end

    private

    def valid_model?(user)
      user.class.includes_all_columns? :token_key, :token_expiration
    end
  end
end