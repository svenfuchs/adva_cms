class ContactMailsController < BaseController
  protect_from_forgery :except => 'create'
  
  def create
    ContactMailer.deliver_contact_mail(params[:contact_mail])
    redirect_to params[:return_to] || '/'
  end
end