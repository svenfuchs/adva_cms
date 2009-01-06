class Newsletter < BaseNewsletter
  has_many :issues, :dependent => :destroy
  has_many :deleted_issues
  has_many :subscriptions, :as => :subscribable
  has_many :users, :through => :subscriptions

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
end
