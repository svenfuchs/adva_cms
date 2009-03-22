class BaseIssue < ActiveRecord::Base
  set_table_name :issues
  
  def owners
    owner.owners << owner
  end

  def owner
    newsletter
  end
end
