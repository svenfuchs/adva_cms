include Authentication::HashHelper

class ContactMailerCell < BaseCell
  tracks_cache_references :recent, :track => ['@section', '@articles']
  
  has_state :recent
  
  helper :content, :resource, :contact_mailer
  
  def mailer_form
    @recipients = URI.escape(EzCrypto::Key.encrypt_with_password(ContactMail.password, send(:site_salt), @opts["recipients"])) if @opts["recipients"]
    @subject    = @opts["subject"]                if @opts["subject"]
    @fields     = @opts["fields"].delete("field") if @opts["fields"]
    nil
  end
end