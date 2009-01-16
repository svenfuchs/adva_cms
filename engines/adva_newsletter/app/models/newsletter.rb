class Newsletter < BaseNewsletter
  has_many :issues, :dependent => :destroy
  has_many :deleted_issues
  has_many :subscriptions, :as => :subscribable
  has_many :users, :through => :subscriptions
  
  before_save :do_not_save_default_email

  def published?
    self.published == 1
  end
  
  def state
    published? ? "published" : "pending"
  end

  def destroy
    self.deleted_at = Time.now.utc
    self.type = "DeletedNewsletter"
    self.save
    return self
  end
  
  def available_users
    site = Site.find(self.site_id, :include => :users)
    reject_user_ids = self.subscriptions.map {|sc| sc.user_id}
    users = site.users.reject {|user| reject_user_ids.include?(user.id)}
  end
  
  def default_email
    self.email.blank? ? self.site.email : self.email
  end
  
  def do_not_save_default_email
    self.email = nil if self.email == self.site.email
  end
end
