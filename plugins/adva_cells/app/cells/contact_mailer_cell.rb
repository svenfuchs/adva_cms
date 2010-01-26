class ContactMailerCell < BaseCell
  include Authentication::HashHelper

  helper :contact_mailer
  has_state :mailer_form
  
  def mailer_form
    symbolize_options!

    @success_message = @opts[:success_message] || I18n.t(:'adva.contact_mails.delivered')
    @failure_message = @opts[:failure_message] || I18n.t(:'adva.contact_mails.delivery_failed')

    @recipients  = URI.escape(EzCrypto::Key.encrypt_with_password(ContactMail.password, site_salt, Array(@opts[:recipients]).join(', ')))
    @subject     = @opts[:subject]
    @fields      = @opts[:fields][:field] if @opts[:fields]
    @id          = @opts[:form_id] || 'contact_mail_form'
    @submit_text = @opts[:submit_text] || I18n.t(:'adva.common.labels.submit')
    nil
  end
end