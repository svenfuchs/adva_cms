class ContactMailer < ActionMailer::Base
  def contact_mail(params)
    recipients params[:recipients]
    from       params[:email]
    subject    params[:subject]
               params.delete(:recipients)
    body       :params => params
  end
end