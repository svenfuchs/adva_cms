class Issue < ActiveRecord::Base
  belongs_to :newsletter
  
  attr_accessible :due_at
end
