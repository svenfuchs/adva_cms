class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :subscribable, :polymorphic => true, :counter_cache => true
  
  attr_accessible :user_id

  validates_presence_of :user_id
end
