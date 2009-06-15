class Adva::Subscription < ActiveRecord::Base
  set_table_name "adva_subscriptions"

  belongs_to :user
  belongs_to :subscribable, :polymorphic => true, :counter_cache => true

  # FIXME figure out how nested attributes can deal with requiring user_id with mass assignment
  # validates_presence_of :user_id, :if => lambda { |subscription| subscription.user.nil? }
  validates_uniqueness_of :user_id, :scope => [:subscribable_id, :subscribable_type]

  named_scope :confirmed, :conditions => "confirmed_at IS NOT NULL"

  attr_accessor :subscribe 
end
