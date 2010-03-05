class AccountMailer < ActionMailer::Base
  include Login::MailConfig

  class << self
    def handle_account_registered!(event)
      account = event.object
      user = account.superusers.first
      deliver_signup_verification_email account, user, verification_url(event.source, user)
    end

    def handle_account_additional_account_created!(event)
      # do not send an email if user already verified on first account signup
    end

    protected

      def verification_url(controller, user)
        controller.send :url_with_token, user, 'verification', :action => 'verify'
      end
  end

  def signup_verification_email(account, user, verification_url)
    recipients user.email
    from system_email(verification_url)
    subject "#{subject_prefix}Email Verification"
    body :account => account, :user => user, :verification_url => verification_url
  end
end
