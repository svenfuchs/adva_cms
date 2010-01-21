include Authentication::HashHelper

class ContactMailerCell < BaseCell
  helper :contact_mailer
  
  def mailer_form
    @recipients = URI.escape(EzCrypto::Key.encrypt_with_password(ContactMail.password, send(:site_salt), @opts["recipients"])) if @opts["recipients"]
    @subject    = @opts["subject"]                if @opts["subject"]
    @fields     = @opts["fields"].delete("field") if @opts["fields"]
    nil
  end
end