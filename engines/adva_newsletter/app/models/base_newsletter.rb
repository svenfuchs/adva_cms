class BaseNewsletter < ActiveRecord::Base
  set_table_name :newsletters
  
  def owners
    owner.owners << owner
  end

  def owner
    site
  end
end
