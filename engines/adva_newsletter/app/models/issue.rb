require 'uri'

class Issue < BaseIssue
  belongs_to :newsletter, :counter_cache => true
  has_one :cronjob, :as => :cronable

  attr_accessible :title, :body, :filter, :draft, :tracking_source, :track, :tracking_campaign
  validates_presence_of :title, :body, :newsletter_id

  named_scope :all_included, :include => :newsletter

  filtered_column :body
  filters_attributes :except => [:body, :body_html]

### Public api
  def deliver(options = {})
    options.assert_valid_keys(:later_at,:to)

    deliver_datetime = options[:later_at]
    user = options[:to]

    if user.nil?
      deliver_all(deliver_datetime)
    else
      deliver_to(user)
    end
  end

  def cancel_delivery
    return false unless queued?
    published_state!
  end
  
  def editable?
    !new_record? && (draft? || published?)
  end

### attributes
  def email
    newsletter.default_email
  end
  
  def email_with_name
    newsletter.email_with_name
  end

  def body_html
    has_tracking_enabled? ? track_links(attributes["body_html"]) : attributes["body_html"]
  end

  def due_at
    return nil unless queued?
    cronjob.due_at if cronjob
  end

### State management
  def draft_state!
    return nil unless published?
    self.state = "draft"
    self.published_at = nil
  end

  def draft=(value)
    case value.to_i
    when 0
      published_state!
    when 1
      draft_state!
    end
  end
  
  def published_state!
    return nil unless (draft? || queued?)
    if queued?
      cronjob.destroy
      reload
    end
    self.state = "hold" # state should be "published", but it does not make sence with newsletter issue
    self.published_at = DateTime.now
    save
  end

  def queued_state!
    return nil unless published?
    self.state = "queued"
    self.queued_at = DateTime.now
    save
  end

  def delivered_state!
    return nil unless queued?
    self.state = "delivered"
    self.delivered_at = DateTime.now
    save
  end

### State status
  def draft?
    state == "draft"
  end

  def draft
    published? ? 0 : 1
  end

  def published?
    ["hold", "published"].include?(state)
  end
  
  def queued?
    state == "queued"
  end

  def delivered?
    state == "delivered"
  end
  
  def state_time
    case state
    when "draft"
      updated_at
    when "hold"
      published_at
    when "queued"
      queued_at
    when "delivered"
      delivered_at
    end
  end
  
### Tracking
  def tracking_campaign=(campaign)
    write_attribute(:tracking_campaign, URI.escape(campaign))
  end

  def tracking_source=(source)
    write_attribute(:tracking_source, URI.escape(source))
  end

  def has_tracking_enabled?
    track? && !(newsletter.site.google_analytics_tracking_code.blank? || tracking_campaign.blank? || tracking_source.blank?)
  end

### Delivery
  def deliver_all(datetime = nil)
    return nil unless published?
    queued_state!
    datetime ||= DateTime.now + 3.minutes
    cronjob = self.build_cronjob :command => "Issue.find(#{self.id}).create_emails", :due_at => datetime
    cronjob.save
  end

  def deliver_to(user)
    NewsletterMailer.deliver_issue(self,user)
  end

  def create_emails
    self.newsletter.users.each do |user|
      create_email_to(user)
    end
    delivered_state!
    Email.create_cronjob
  end

  def create_email_to(user)
    issue = NewsletterMailer.create_issue(self,user)
    Email.create(:from => self.newsletter.default_email,
                 :to => user.email,
                 :mail => issue.to_s)
  end
  
  def destroy
    self.deleted_at = Time.now.utc
    self.type = "DeletedIssue"
    if self.save
      Newsletter.update_counters self.newsletter_id, :issues_count => -1
    end
    return self
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
