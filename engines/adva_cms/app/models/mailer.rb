class Mailer < ActionMailer::Base
  def deliver_all
    Email.find_all.each do |mail|
      self.deliver(mail.mail)
    end
  end
end
