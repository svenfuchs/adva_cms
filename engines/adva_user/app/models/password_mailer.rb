class PasswordMailer < ActionMailer::Base
  include Login::MailConfig

  class << self
    def handle_user_password_reset_requested!(event)
      deliver_reset_password_email(:user => event.object, :reset_link => password_reset_link(event.source, event.token), :token => event.token)
    end

    def handle_user_password_updated!(event)
      deliver_updated_password_email(:user => event.object) #, password_reset_link(event.source, '')
    end

    private

      def password_reset_link(controller, token)
        controller.send :url_for, :action => 'edit', :token => token
      end
  end
  
  def reset_password_email(attributes={})
    recipients attributes[:user].email
    from system_email(attributes[:reset_link])
    subject I18n.t(:'adva.passwords.notifications.reset_password.subject')
    body attributes
  end

  def updated_password_email(attributes={})
    recipients attributes[:user].email
    from system_email('') # TODO hu?
    subject I18n.t(:'adva.passwords.notifications.password_updated.subject')
    body attributes
  end
end