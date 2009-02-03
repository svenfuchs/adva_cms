require 'sha1'

module Authentication

  # Generating a hash is a common task across many authentication
  # modules. This mixin makes the task easier.
  module HashHelper
    protected

    # Will hash the given string based on the given salt. The default
    # salt is the site salt. This is defined by the constant
    # AUTHENTICATION_SALT. If not defined then the installation
    # directory of the application will be used as the site salt.
    def hash_string(string, salt=site_salt)
      SHA1.sha1("#{salt}---#{string}").to_s
    end

    private

    # Will retrieve the site salt.
    def site_salt
      return AUTHENTICATION_SALT if Object.const_defined? 'AUTHENTICATION_SALT'
      File.expand_path RAILS_ROOT
    end
  end
end