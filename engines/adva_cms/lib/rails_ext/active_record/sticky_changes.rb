# This stops the record from forgetting changes when the record 
# is saved.
#
# If you're interested in changes between subsequent saves
# you can call #clear_changes! to clear them.

ActiveRecord::Base.class_eval do
  alias :save :save_without_dirty
  alias :save! :save_without_dirty!
  
  def clear_changes! # TODO figure out a better name
    changed_attributes.clear
  end
  
  def state_changes
    if frozen?
      [:deleted]
    elsif just_created?
      [:created]
    elsif changed?
      [:updated]
    else
      []
    end
  end
  
  def just_created?
    !!changes['id'] and changes['id'].first.nil?
  end
end
