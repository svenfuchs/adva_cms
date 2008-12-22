require 'action_mailer'

##
# Adds sending email through an ActiveRecord table as a delivery method for
# ActionMailer.
#
# == Converting to ActionMailer::ARMailer
#
# Go to your Rails project:
#
#   $ cd your_rails_project
#
# Create a new migration:
#
#   $ ar_sendmail --create-migration
#
# You'll need to redirect this into a file.  If you want a different name
# provide the --table-name option.
#
# Create a new model:
#
#   $ ar_sendmail --create-model
#
# You'll need to redirect this into a file.  If you want a different name
# provide the --table-name option.
#
# You'll need to be sure to set the From address for your emails.  Something
# like:
#
#   def list_send(recipient)
#     from 'no_reply@example.com'
#     # ...
#
# Edit config/environment.rb and require ar_mailer.rb:
#
#  require 'action_mailer/ar_mailer'
#
# Edit config/environments/production.rb and set the delivery agent:
#
#   $ grep delivery_method config/environments/production.rb
#   ActionMailer::Base.delivery_method = :activerecord
#
# Run ar_sendmail:
#
#   $ ar_sendmail
#
# You can also run it from cron with -o, or as a daemon with -d.
#
# See <tt>ar_sendmail -h</tt> for full details.
#
# == Alternate Mail Storage
#
# If you want to set the ActiveRecord model that emails will be stored in,
# see ActionMailer::ARMailer::email_class=

module ActionMailer
  module ARMailer
    
    def self.included(base)
      #base.send(:cattr_accessor, :email_class)
      base.send(:cattr_accessor, :email_class_name)
      base.email_class_name = 'Email'
      base.extend ClassMethods
    end

    module ClassMethods
      def email_class
        email_class_name.constantize 
      end
    end
    
    ##
    # Adds +mail+ to the Email table.  Only the first From address for +mail+ is
    # used.
    def perform_delivery_activerecord(mail)
      mail.destinations.each do |destination|
        self.class.email_class.create :mail => mail.encoded,
            :to => destination, :from => mail.from.first
      end
    end
    
  end
end
