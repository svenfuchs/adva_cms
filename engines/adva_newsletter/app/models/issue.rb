class Issue < ActiveRecord::Base
  belongs_to :newsletter

  attr_accessible :title, :desc
end
