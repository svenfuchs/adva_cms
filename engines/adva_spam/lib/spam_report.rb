class SpamReport < ActiveRecord::Base
  belongs_to :subject, :polymorphic => true
  serialize :data
end