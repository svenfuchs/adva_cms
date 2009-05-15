class Adva::Mailer < ActionMailer::Base
  def deliver_all
    Adva::Email.find_all.each do |mail|
      self.deliver(mail.mail)
    end
  end
end
