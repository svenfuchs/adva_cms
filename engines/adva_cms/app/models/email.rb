class Email < ActiveRecord::Base
  attr_accessible :from, :to, :mail
  validates_presence_of :from, :to, :mail
  
  class << self
    def create_cronjob
      Cronjob.create :cron_id => "email_deliver_all", :command => "Email.deliver_all"
    end
    
    def deliver_all
      self.find(:all, :limit => 25).each do |email|
        if email.present?
          Mailer.deliver(TMail::Mail.parse(email.mail))
          email.destroy
        end
      end
      autoremove_cronjob
    end

  private
    def autoremove_cronjob
      cronjob = Cronjob.find_by_cron_id("email_deliver_all")
      cronjob.destroy if Email.first.blank? && cronjob.present?
    end
  end
end
