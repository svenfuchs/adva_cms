require 'authentication/hash_helper'

module Authentication
  # Implements a basic salted hash authentication is the model's table.
  # The model must implement the fields "password_hash" and
  # "password_salt". If those fields are not implemented then this
  # module cannot authenticate the user. These fields should be a
  # string of 40 characters.
  #
  # NOTE: Some concepts here were borrowed from the Salted Login
  # Generator/Engine. I am not a security expert but this seems like it
  # would be quite safe and implements "best practice" methods for
  # authentication. I'm sure there are better ones but this is much
  # better than my old apps which used clear text passwords in the
  # databse. :)
  #
  # NOTE: There is a hidden feature here. If the model contains
  # the column "verified_at" then the user will not authenticate
  # until the verified_at column has a value. This is to support the
  # common practice of requiring a user to verify their email address
  # before being able to login. If the column is not defined then
  # the user can login as long as their password is correct.
  class SaltedHash
    include HashHelper

    # Carries out actual authentication procedure. If the password
    # given is correct for the given user then true is returned.
    # Otherwise false will be returned.
    def authenticate(user, password)
      return false unless valid_model?(user)

      password_hash = hash_string password, user.password_salt
      conditions = ['id = ? AND password_hash = ?', user.id, password_hash]
      conditions[0] << ' AND verified_at IS NOT NULL' if user.respond_to? :verified_at
      0 < user.class.count(:conditions => conditions)
    end

    # Will assign a new password for the given user.
    def assign_password(user, password)
      return unless valid_model? user

      user.password_salt = hash_string "salt-#{Time.zone.now}"
      user.password_hash = hash_string password, user.password_salt
    end

    private

    # True if password_hash and password_salt not in the table
    def valid_model?(user)
      user.class.includes_all_columns? :password_hash, :password_salt
    end
  end
end