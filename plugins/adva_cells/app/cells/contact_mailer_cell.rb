class ContactMailerCell < BaseCell
  include Authentication::HashHelper

  helper :contact_mailer
  has_state :mailer_form
  
  def mailer_form
    symbolize_options!

    @recipients  = URI.escape(EzCrypto::Key.encrypt_with_password(ContactMail.password, site_salt, Array(@opts[:recipients]).join(', ')))
    @subject     = @opts[:subject]
    @fields      = @opts[:fields][:field] if @opts[:fields]
    @id          = @opts[:form_id] || 'contact_mail_form'
    @submit_text = @opts[:submit_text] || I18n.t(:'adva.common.labels.submit')
    nil
  end
end