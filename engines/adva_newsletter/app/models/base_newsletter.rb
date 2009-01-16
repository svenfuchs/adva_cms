class BaseNewsletter < ActiveRecord::Base
  set_table_name :newsletters
  belongs_to :site
  
  attr_accessible :title, :desc, :published, :email
  validates_presence_of :title, :site_id

  named_scope :all_included, :include => [:issues,:subscriptions]
end
