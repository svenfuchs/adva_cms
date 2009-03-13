ActiveRecord::Base.class_eval do
  def exists?
    !new_record?
  end
end