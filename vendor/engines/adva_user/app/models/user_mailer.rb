class UserMailer < ActionMailer::Base
  include Login::MailConfig

  class << self
    def handle_user_registered!(event)
      deliver_signup_verification_email event.object, verification_url(event.source, event.object)
    end
    
    protected
    
      def verification_url(controller, user)
        controller.send :url_with_token, user, 'verification', :action => 'verify'
      end
  end

  def signup_verification_email(user, verification_url)
    recipients user.email
    from system_email(verification_url)
    subject "#{subject_prefix}Email Verification"
    body :user => user, :verification_url => verification_url
  end
end
