class Newsletter < BaseNewsletter

  has_many :issues, :dependent => :destroy
  has_many :deleted_issues
  has_many :subscriptions, :as => :subscribable

  def destroy
    self.deleted_at = Time.now.utc
    self.type = "DeletedNewsletter"
    self.save
    return self
  end
end
