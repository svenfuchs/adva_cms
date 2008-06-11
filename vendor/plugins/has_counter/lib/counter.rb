class Counter < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
  
  def increment!
    self.count += 1
    save!
  end
  
  def decrement!
    self.count -= 1
    save!
  end
  
  def set(value)
    self.count = value
    save!
  end
end