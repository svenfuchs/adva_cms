class Newsletter < ActiveRecord::Base
  belongs_to :site
  has_many :issues, :dependent => :destroy
  has_many :subscriptions, :as => :subscribable
  
  attr_accessible :title, :desc

  validates_presence_of :title

  named_scope :all_included, :include => :issues
end
