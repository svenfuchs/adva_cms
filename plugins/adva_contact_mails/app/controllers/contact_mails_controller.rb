include Authentication::HashHelper

class ContactMailsController < BaseController
  protect_from_forgery :except => 'create'
  
  before_filter :decrypt_recipients, :only => :create
  
  def create
    ContactMailer.deliver_contact_mail(params[:contact_mail])
    flash[:notice] = t(:'adva.contact_mails.delivered')
    redirect_to params[:return_to] || '/'
  end
  
  protected
    
    def decrypt_recipients
      if params[:contact_mail] && params[:contact_mail][:recipients]
        recipients = URI.unescape(params[:contact_mail][:recipients])
        params[:contact_mail][:recipients] = EzCrypto::Key.decrypt_with_password(ContactMail.password, send(:site_salt), recipients)
      end
    end
end