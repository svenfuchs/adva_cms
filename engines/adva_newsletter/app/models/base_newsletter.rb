class BaseNewsletter < ActiveRecord::Base
  set_table_name :newsletters

  belongs_to :site
  
  attr_accessible :title, :desc
  validates_presence_of :title

  named_scope :all_included, :include => [:issues,:subscriptions]
end
