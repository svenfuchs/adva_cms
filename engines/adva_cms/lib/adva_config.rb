module Adva
  module Config
    mattr_accessor :number_of_outgoing_mails_per_process
    @@email_header ||= {}

    class << self
      def number_of_outgoing_mails_per_process
        @@number_of_outgoing_mails_per_process ||= 150
      end
      
      def email_header
        @@email_header
        {
          # TODO: define default values when initializer values are missing
          # "Return-path" => "site@example.org",
          # "Sender" => "site@example.org",
          # "Reply-To" => "site@example.org",
          # "X-Originator-IP" => "0.0.0.0"
          "X-Mailer" => "Adva-CMS"
        }.merge(@@email_header)
      end

      def email_header=(options = {})
        @@email_header.merge!(options)
      end
    end
  end
end
