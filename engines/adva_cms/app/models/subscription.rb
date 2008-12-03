class Subscription < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true, :counter_cache => true
  belongs_to :newsletter,  :class_name => 'Newsletter',
                           :foreign_key => 'newsletter_id'
  
  attr_accessible :user_id, :commentable_id, :commentable_type

  validates_presence_of :user_id
  validates_presence_of :commentable_id
  validates_presence_of :commentable_type
end
