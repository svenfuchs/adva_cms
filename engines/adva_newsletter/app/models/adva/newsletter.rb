class Adva::Newsletter < ActiveRecord::Base
  set_table_name "adva_newsletters"

  belongs_to :site
  has_many :issues, :dependent => :destroy, :class_name => "Adva::Issue"
  has_many :subscriptions, :as => :subscribable, :class_name => "Adva::Subscription"
  has_many :users, :through => :subscriptions

  attr_accessible :title, :desc, :published, :email
  validates_presence_of :title, :site_id

  named_scope :all_included, :include => [:issues,:subscriptions]
  named_scope :published, :conditions => "adva_newsletters.published = 1"

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
  
  def email
    read_attribute(:email).present? ? read_attribute(:email) : site.email
  end

  def name
    read_attribute(:name).present? ? read_attribute(:name) : site.name
  end

  def email_with_name
    "#{name} <#{email}>"
  end

  def do_not_save_default_email
    self.email = nil if email == site.email
  end
end
