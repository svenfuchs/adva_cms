class Project < ActiveRecord::Base
  belongs_to :tracker
  
  attr_accessible :title, :desc
  validates_presence_of :title
  
  def editable?
    !new_record?
  end
end
