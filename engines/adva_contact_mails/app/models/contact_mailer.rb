class ContactMailer < ActionMailer::Base
  def contact_mail(params)
    recipients params[:recipients]
    from       params[:email]
    subject    params[:subject]
    body       params
  end
end