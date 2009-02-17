class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :subscribable, :polymorphic => true, :counter_cache => true

  validates_presence_of :user_id, :if => lambda { |subscription| subscription.user.nil? }
  validates_uniqueness_of :user_id, :scope => [:subscribable_id, :subscribable_type]

  named_scope :confirmed, :conditions => "confirmed_at IS NOT NULL"
end
