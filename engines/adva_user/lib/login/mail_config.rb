module Login

  # The purpose of this module is to provide an application some control
  # over how the messages are sent without having to overwrite blocks
  # of code. We do this through simple constants. The two constants
  # currently are:
  #
  # SUBJECT_PREFIX::
  #   Text that is before every message subject. By default this is not
  #   used. You may want to put something like the website here.
  # NOTIFICATIONS_FROM::
  #   Who the message appears to be coming from. By default this is
  #   postmaster@yourdomain.com
  #
  # If you want to access these same values in your own mailers just
  # mix them into your mailers and the methods will be available.
  module MailConfig
    protected

    # Will return subject prefix
    def subject_prefix
      return "[#{SUBJECT_PREFIX}] " if Object.const_defined?('SUBJECT_PREFIX')
      ''
    end

    # Email message appear to come from. The constant takes priority
    # but if no constant is defined then the email is extracted from
    # the given param which can be any link that you want the email
    # to appear to come from.
    def system_email(extract_from)
      return NOTIFICATIONS_FROM if Object.const_defined?('NOTIFICATIONS_FROM')
      if host = URI.parse(extract_from).host
        host = host.split '.'
        host.shift if host.first =~ /www/i
        "postmaster@#{host * '.'}"
      end
    end
  end
end