require 'action_mailer'

module ARMailer
  class << self
    def enable
      enable_actionmailer
    end
    
    # mixes in ActionMailer::ARMailer in ActionMailer::Base
    def enable_actionmailer
      return if ActionMailer::Base.instance_methods.include? 'perform_delivery_activerecord'
      ActionMailer::Base.class_eval { include ActionMailer::ARMailer }
    end
  end
end

if defined?(Rails) and defined?(ActionMailer)
  ARMailer.enable
end
