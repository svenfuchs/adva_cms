require 'authentication/hash_helper'

module Authentication

  # This token module works mostly like the SingleToken module with
  # three differences:
  #
  # * It uses a different field name (remember_me CHAR(40))
  # * It doesn't care about any expiration time set
  # * It will only assign a token if the token name is /remember.?me/i
  #
  # This module is ideally suited for the remember me functionality
  # because of these changes. This module would probably not be
  # necessary if you are using a token module that supports more than
  # one token. Since the default one (SingleToken) only supports one
  # we need a seperate module for the remember me functionality so
  # we can basically now store two tokens by default.
  #
  # This module supports the same "verified_at" hidden feature that
  # the Authentication::SaltedHash module supports
  class RememberMe
    include HashHelper

    # Will test to see if the given remember me key is valid
    def authenticate(user, key)
      return false unless valid_model? user
      return false unless key.to_s.length == 40

      conditions = ['id = ? AND remember_me = ?', user.id, hash_string(key)]
      conditions[0] << ' AND verified_at IS NOT NULL' if user.respond_to? :verified_at
      0 < user.class.count(:conditions => conditions)
    end

    # Will create a new remember me token. We will ignore the expiration
    # since a remember me is always forever.
    def assign_token(user, name, expire=nil)
      return nil unless valid_model? user
      return nil unless name =~ /remember.?me/i

      token = hash_string "remember-me-#{Time.zone.now}"
      user.remember_me = hash_string token
      token
    end

    private

    # This functionality is only used if remember me an available column
    def valid_model?(user)
      user.class.column_names.include? 'remember_me'
    end
  end
end