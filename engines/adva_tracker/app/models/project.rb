class Project < ActiveRecord::Base
  belongs_to :section
  acts_as_role_context :parent => Section

  has_many :tickets, :as => :ticketable

  
  attr_accessible :title, :desc
  validates_presence_of :title
  
  def editable?
    !new_record?
  end
end
