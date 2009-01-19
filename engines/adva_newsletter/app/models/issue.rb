class Issue < BaseIssue
  belongs_to :newsletter, :counter_cache => true
  has_many :cronjobs, :as => :cronable

  attr_accessible :title, :body, :filter, :draft
  validates_presence_of :title, :body, :newsletter_id

  named_scope :all_included, :include => :newsletter

  filtered_column :body
  filters_attributes :except => [:body, :body_html]

  def body_html
    has_tracking_enabled? ? track_links(attributes["body_html"]) : attributes["body_html"]
  end

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

  def has_tracking_enabled?
    track? && !(newsletter.site.google_analytics_tracking_code.blank? || tracking_campaign.blank? || tracking_source.blank?)
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
  
private
  def track_links(content)
    content.gsub(/<a(.*)href="#{Regexp.escape("http://#{newsletter.site.host}")}(.*)"(.*)>/) do |s|
      m = [$1, $2, $3] # why do I need this?
      returning %(<a#{m[0]}href="http://#{newsletter.site.host}) do |s|
        s << ("#{m[1]}#{m[1].include?("?") ? "&" : "?"}utm_medium=newsletter&utm_campaign=#{tracking_campaign}&utm_source=#{tracking_source}") if m[1]
        s << %("#{m[2]}>)
      end
    end
  end
end
