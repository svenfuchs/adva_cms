require 'uri'

class Adva::Issue < ActiveRecord::Base
  set_table_name "adva_issues"

  belongs_to :newsletter, :counter_cache => true, :class_name => "Adva::Newsletter"
  has_one :cronjob, :as => :cronable, :class_name => "Adva::Cronjob"

  attr_accessible :title, :body, :body_plain, :filter, :draft, :deliver_at
  validates_presence_of :title, :body, :newsletter_id

  named_scope :all_included, :include => :newsletter

  filtered_column :body
  filters_attributes :except => [:body, :body_html]

  is_paranoid 

  def owners
    owner.owners << owner
  end

  def owner
    newsletter
  end

  # public api

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

  # attributes

  def email
    newsletter.email
  end

  def email_with_name
    newsletter.email_with_name
  end

  # state management

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
      cronjob.destroy if cronjob
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

  # state status

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

  # delivery

  def deliver_all(datetime = nil)
    return nil unless published?
    if datetime.nil?
      self.deliver_at = (Time.zone.now + 3.minutes)
    else
      update_attributes(datetime)
    end

    if save
      cronjob = self.build_cronjob :command => "Adva::Issue.find(#{self.id}).create_emails", :due_at => deliver_at
      queued_state! if cronjob.save
    end
  end

  def deliver_to(user)
    Adva::NewsletterMailer.deliver_issue(self,user)
  end

  def create_emails
    delivered_state!
    if newsletter.subscriptions.present?
      newsletter.users.each do |user|
        create_email_to(user)
      end
      Adva::Email.start_delivery
    end
  end

  def create_email_to(user)
    issue = Adva::NewsletterMailer.create_issue(self,user)
    Adva::Email.create(:from => self.newsletter.email,
                       :to => user.email,
                       :mail => issue.to_s)
  end
  
  def images
    @images ||= Adva::IssueImage.parse(body_html)
  end
  
  def body_mail
    body = body_html.dup
    images.each do |image|
      body.sub!(image.uri, "cid:#{image.cid_plain}")
    end  
    body
  end
end
