class Issue < BaseIssue
  belongs_to :newsletter, :counter_cache => true
  validates_presence_of :newsletter_id
  has_many :cron_jobs, :as => :cronable

  def deliver(options = {})
    options.assert_valid_keys(:later_at,:to)

    deliver_datetime = options[:later_at]
    user = options[:to]
    
    if user.nil?
      deliver_all(deliver_datetime)
    else
      deliver_to!(user)
    end
  end
  
  def destroy
    self.deleted_at = Time.now.utc
    self.type = "DeletedIssue"
    if self.save
      Newsletter.update_counters self.newsletter_id, :issues_count => -1
    end
    return self
  end
  
  def deliver_all(datetime = nil)
    datetime ||= DateTime.now + 3.minutes
    self.cron_jobs.create :command => "Issue.find(#{self.id}).create_emails", :due_at => datetime
  end
  
  def deliver_to!(user)
    NewsletterMailer.deliver_issue(self,user)
  end
  
  def create_emails
    self.newsletter.users.each do |user|
      create_email_to(user)
    end
    self.published_at = Time.now.utc
    self.save
  end
  
  def create_email_to(user)
    issue = NewsletterMailer.create_issue(self,user)
    Email.create(:from => self.newsletter.site.email,
                 :to => user.email,
                 :mail => issue.encoded)
  end
end
