class Issue < ActiveRecord::Base
  belongs_to :newsletter, :counter_cache => true

  attr_accessible :title, :body

  validates_presence_of :title, :body

  def draft?
    true
  end
end
