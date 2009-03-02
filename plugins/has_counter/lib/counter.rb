class Counter < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
  
  def increment!
    set count + 1
  end
  
  def increment_by!(value)
    set count + value
  end
  
  def decrement!
    set count - 1
  end
  
  def decrement_by!(value)
    set count - value
  end
  
  def set(value)
    update_attributes! :count => value
  end
end