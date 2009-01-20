module Adva
  module Config
    mattr_accessor :number_of_outgoing_mails_per_process

    class << self
      def number_of_outgoing_mails_per_process
        @@number_of_outgoing_mails_per_process ||= 150
      end
    end
  end
end
