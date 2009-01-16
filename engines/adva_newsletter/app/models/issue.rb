class Issue < BaseIssue
  belongs_to :newsletter, :counter_cache => true
  has_many :cronjobs, :as => :cronable

  validates_presence_of :newsletter_id

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
  
  def email
    self.newsletter.default_email
  end
  
  def state
    if self.published_at.present? && !self.draft?
      "published"
    elsif self.published_at.nil? && self.draft?
      "pending"
    elsif self.published_at.nil? && !self.draft?
      ""
    end
  end
  
  def draft?
    self.draft == 1
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
    self.cronjobs.create :command => "Issue.find(#{self.id}).create_emails", :due_at => datetime
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
    Email.create_cronjob
  end
  
  def create_email_to(user)
    issue = NewsletterMailer.create_issue(self,user)
    Email.create(:from => self.newsletter.site.email,
                 :to => user.email,
                 :mail => issue.encoded)
  end
end
