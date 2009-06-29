class Adva::Email < ActiveRecord::Base
  set_table_name "adva_emails"

  attr_accessible :from, :to, :mail
  validates_presence_of :from, :to, :mail
  
  class << self
    def start_delivery
      Adva::Cronjob.create :cron_id => "email_deliver_all", :command => "Adva::Email.deliver_all"
    end
    
    def deliver_all
      self.find(:all, :limit => Registry.instance[:number_of_outgoing_mails_per_process]).each do |email|
        if email.present?
          Adva::Mailer.deliver(TMail::Mail.parse(email.mail))
          email.destroy
        end
      end
      autoremove_cronjob
    end

  private
    def autoremove_cronjob
      cronjob = Adva::Cronjob.find_by_cron_id("email_deliver_all")
      cronjob.destroy if Adva::Email.first.blank? && cronjob.present?
    end
  end
end
