class Issue < ActiveRecord::Base
  belongs_to :newsletter

  attr_accessible :title, :body

  validates_presence_of :title
  validates_presence_of :body

  def draft?
    true
  end
end
