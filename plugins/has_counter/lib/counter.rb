class Counter < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
  
  def increment!
    set count + 1
  end
  
  def decrement!
    set count - 1
  end
  
  def set(value)
    self.count = value
    save!
  end
end