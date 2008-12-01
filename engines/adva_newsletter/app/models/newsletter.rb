class Newsletter < ActiveRecord::Base
  has_many :issues
  
  attr_accessible :title, :body
  validates_presence_of :title
  validates_presence_of :body 

  named_scope :all_included, :include => :issues

  def draft?
    true
  end
end
