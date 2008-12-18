class BaseIssue < ActiveRecord::Base
  set_table_name :issues

  attr_accessible :title, :body
  validates_presence_of :title, :body

  named_scope :all_included, :include => :newsletter
  # named_scope :active,       :conditions => {'deleted_at' => nil}
  # named_scope :deleted,      :conditions => 'deleted_at IS NOT NULL'

  def draft?
    true
  end
end
