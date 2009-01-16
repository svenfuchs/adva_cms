class BaseIssue < ActiveRecord::Base
  set_table_name :issues

  attr_accessible :title, :body, :draft
  validates_presence_of :title, :body

  named_scope :all_included, :include => :newsletter

  def draft?
    self.draft == 1
  end
end
