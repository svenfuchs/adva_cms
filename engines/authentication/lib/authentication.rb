require 'authentication/salted_hash'
require 'authentication/remember_me'
require 'authentication/single_token'

# This module provides the infrastructure for implementing a pluggable
# authentication system.
#
# This plugin was created in similar spirit to the Authen::Simple CPAN
# module in Perl. The internal design is different but the goal is the
# same. A chain of authentication systems can be registered. When a user
# attempts to authenticate it will cycle through this chain until it can
# authenticate successfully.
#
# This allows you to have multiple authentication attempts (perhaps a
# ActiveDirectory auth, followed by a POP3 auth, followed by an auth on
# the local database). This also allows the authentication mechanism to
# be switched out with mimimal affects on the code.
#
# The goal is eventually to include with this plugin a variety of
# authentication methods with sane defaults. Depending on the
# environment the authentication method can be easily changed and
# chained. Right now we only support authenticating with the local
# database.
#
# See Authentication::Macros for usage info
module Authentication

  mattr_accessor :default_scheme
  self.default_scheme = {
      :authenticate_with => 'Authentication::SaltedHash',
      :token_with => [
        'Authentication::RememberMe',
        'Authentication::SingleToken'
      ]
  }

  module Macros

    # Should be called on whatever ActiveRecord::Base subclass is
    # being authenticated (i.e. User, Profile, etc.). The common
    # case should look something like:
    #
    #   class User < ActiveRecord::Base
    #     acts_as_authenticated_user
    #   end
    #
    # Most of the time you will simply call this method with no
    # arguments. In this case sane defaults will cause the
    # application to authenticate with the local database. These
    # sane defaults will attempt to provide you with the following:
    #
    # * A salted hash password authentication
    # * A single token authentication ideal for URL tokens
    # * A remember me authentication ideal for cookie remember me
    #   functionality
    #
    # Those methods will only be provided if the model being
    # authenticated provides the proper fields. See the documentation
    # on those various authentication modules for what is required
    # to make a module work.
    #
    # If you are interested in using other modules then you need to know
    # the following:
    #
    # There are two types of authentication modules.
    # The password auth type has the traditional user/password
    # requirement to authenticate. A user can also typically change
    # their password (although this is not required). An example
    # of this module is the Authentication::SaltedHash module.
    #
    # The other type of module is a token module. A token module
    # typically consist of a user and some sort of token that is
    # not usually user entered. For example a single-signon system
    # may use a token to avoid having to prompt the user. Examples
    # of token modules are the Authentication::SingleToken module
    # and the Authentication::RememberMe module. A token module may
    # authenticate many different tokens for the same user. This allows
    # a token module to assign different valid tokens to different
    # systems so that a token can be revoked if desired. Token
    # authentications often also have a time expiration that a token
    # is valid for. After that time has expired the token no longer
    # works.
    #
    # If you desire to change the modules used this macro method
    # accepts two options in the option hash. The option
    # :authenticate_with is how you specify one or more password auth
    # modules. The option :token_with is how you specify one or more
    # token modules to authenticate with.
    #
    # Both options can accept values in following formats:
    #
    # single module::
    #   In this case a single module name is provided to authenticate
    #   against. For example:
    #     acts_as_authenticated_user :authenticate_with => 'Authentication::POP3'
    # chain of modules::
    #   In this case a list of modules will be used to authenticate
    #   against. If any of them are a success then the user
    #   authenticates. Otherwise the user will not successfully login.
    #   For example:
    #     acts_as_authenticated_user :authenticate_with =>
    #       ['Authentication::ActiveDirectory', 'Authentication::POP3']
    # module with arguments::
    #   In this case a single module is being used but it has arguments
    #   which are passed to the module when instantated. For example:
    #     acts_as_authenticated_user :authenticate_with =>
    #       {'Authentication::POP3' => ['pop3.example.org', 110]}
    #   In this case the code will call
    #   Authentication::POP3.new('pop3.example.org', 110) when
    #   instantionating the object. More than likely the authentication
    #   module will just have one argument which is an option hash. In
    #   this case you might initialize that module like the following:
    #     acts_as_authenticated_user :authenticate_with =>
    #       {'Authentication::POP3' =>
    #       {:server => 'pop3.example.org', :port => 110}}
    # chain of modules with arguments::
    #   You can also chain modules and use arguments. In this case you
    #   just pass the method an array of hashes. For example:
    #     acts_as_authenticated_user :authenticate_with =>
    #       [
    #         {'Authentication::POP3' =>
    #           {:server => 'pop3.example.com', :port => 5000}},
    #         {'Autnentication::ActiveDirectory' =>
    #           {:server => 'ad.example.com'}}
    #       ]
    #
    # If you wish to provide a different scheme depending on the
    # environment (i.e. production vs. development) then you can
    # assign your argument to the Module method "default_scheme"
    # on the Authentication module in the proper environment file.
    # For example:
    #
    #   Authentication.default_scheme = {
    #     :authenticate_with => 'Authentication::POP3',
    #     :token_with => []
    #   }
    #
    # This would authenticate with POP3 and not provide any token
    # mechanism.
    def acts_as_authenticated_user(options={})
      options.reverse_merge! Authentication.default_scheme

      # Process arguments and store in instantiated auth modules
      {
        :authenticate_with => :authentication_modules,
        :token_with => :token_modules,
      }.each do |option, mod_type|
        mods = [options[option]].flatten.compact
        mods = mods.inject([]) do |memo, mod|
          if mod.is_a? Hash
            mod.each do |m, args|
              args = [args] unless args.is_a? Array
              memo << m.constantize.new(*args)
            end
          else
            memo << mod.constantize.new
          end
          memo
        end
        class_inheritable_accessor mod_type
        private
        self.send "#{mod_type.to_s}=".to_sym, mods
      end

      include Authentication::InstanceMethods
      if method_defined?(:password=) # TODO rather have these in the client class?
        before_validation :assign_password
        # after_save :reset_password
      end
    end
  end

  # Methods that are mixed into the authenticated object as instance
  # methods.
  module InstanceMethods
    # If the given password will authenticate the object using
    # the chain of authentication modules configured then true is
    # returned. Otherwise false is returned. Both token modules
    # and password auth modules are checked.
    def authenticate(password)
      mods = [
        self.class.token_modules,
        self.class.authentication_modules
      ].flatten.compact
      mods.each {|mod| return true if mod.authenticate self, password}
      false
    end

    # Will create a new token that can be used to login without a
    # password (or basically you can consider this just a really
    # complex password). If this token is passed into the authenticate
    # method then true should be returned. This method takes the
    # following three arguments:
    #
    # name:: Depending on the token modules used will determine if this
    # argument has any meaning. Sometimes a token module will only
    # respond to one name. Other times it will respond to any name.
    # The reason for this parameter is to allow a token module to
    # have multiple tokens it accepts so that it can then later revoke
    # only some tokens if needed. For example a site trying to provide
    # single-signon service may give out a token for each foreign system
    # that interacts with it. Then later when that token is used the
    # token module can note what system it authenticated for and if at
    # some point it stops trusting the foreign system it can revoke
    # that token without revoking the other tokens it has assigned.
    #
    # An expiration date can also be given although not all token
    # modules will do anythign with this expiration date.
    #
    # NOTE: If the token generated is attached to the model (default
    # behavior) then the token may not actually valid until the model
    # has been saved. To be sure always call save after getting a new
    # token if you want to be sure to keep that token.
    def assign_token(name, expire=3.days.from_now)
      self.class.token_modules.each do |mod|
        token = mod.assign_token self, name, expire if mod.respond_to? :assign_token
        return token if token
      end
      nil
    end

    def assign_token!(*args)
      returning assign_token(*args) do |token|
        save!
      end
    end

    # Will assign a new password that will by crypted on when the
    # model is saved. If multiple password auth modules are configured
    # then each one will be given a copy of this new password. This
    # could be a useful method of syncing your passwords across
    # different systems. Not all password auth modules support the
    # ability to change passwords.
    attr_writer :password

    # For confirmation validation
    # previously this was private, which seems to cause validates_presence_of :password
    # to fail, therefor made it public
    attr_reader :password

    private

    # before_validation callback let authentication modules set password.
    # If a module does not allow setting a password it should just not implement
    # the assign_password function.
    #
    # NOTE: If password is blank nothing is done. This is to prevent
    # the common case of empty passwords on a form from blanking out a
    # password. The side effect is that you cannot specifically have a
    # blank password.
    def assign_password
      return true if password.blank?
      self.class.authentication_modules.each do |mod|
        mod.assign_password self, password if mod.respond_to? :assign_password
      end
      true
    end

    # Callback after save to ensure cleartext password is deleted
    def reset_password
      self.password = nil
      self.password_confirmation = nil if respond_to? :password_confirmation
    end
  end
end
