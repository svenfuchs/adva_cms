class Counter < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
  
  def increment!
    self.count ++
    save!
  end
  
  def set(value)
    self.count = value
    save!
  end
end