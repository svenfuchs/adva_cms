class Newsletter < ActiveRecord::Base
  belongs_to :site
  has_many :issues, :dependent => :destroy, :class_name => "Adva::Issue"
  has_many :subscriptions, :as => :subscribable
  has_many :users, :through => :subscriptions

  attr_accessible :title, :desc, :published, :email
  validates_presence_of :title, :site_id

  named_scope :all_included, :include => [:issues,:subscriptions]
  named_scope :published, :conditions => "newsletters.published = 1"

  before_save :do_not_save_default_email

  is_paranoid

  def owners
    owner.owners << owner
  end

  def owner
    site
  end

  def published?
    self.published == 1
  end

  def state
    published? ? "published" : "pending"
  end

  def available_users
    site = Site.find(self.site_id, :include => :users)
    reject_user_ids = self.subscriptions.map {|sc| sc.user_id}
    users = site.users.reject {|user| reject_user_ids.include?(user.id)}
  end

  def default_email
    email.blank? ? site.email : email
  end

  def default_name
    name.blank? ? site.name : name
  end

  def email_with_name
    "#{default_name} <#{default_email}>"
  end

  def do_not_save_default_email
    self.email = nil if self.email == self.site.email
  end
end
