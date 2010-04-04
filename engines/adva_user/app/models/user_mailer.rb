class UserMailer < ActionMailer::Base
  class << self
    def handle_user_registered!(event)
      deliver_signup_verification_email(
        :user => event.object, 
        :verification_url => verification_url(event.source, event.object), 
        :from => site(event.source.site).email_from
      )
    end
    
    protected
    
      def verification_url(controller, user)
        controller.send(:url_with_token, user, 'verification', :action => 'verify')
      end
  end

  def signup_verification_email(attributes = {})
    recipients attributes[:user].email
    from       attributes[:from]
    subject    I18n.t(:'adva.signup.notifications.email_verification.subject')
    body       attributes
  end

  def user_invitation(confirmation_url, invitation)
    recipients  invitation.email
    from        invitation.site.email
    subject     I18n.t(:'adva.users.emails.user_invitation.subject')
    body        :account_name => invitation.site.account.name, :confirmation_url => confirmation_url 
  end
end
