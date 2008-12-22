class CronJob < ActiveRecord::Base
  belongs_to :cronable, :polymorphic => true
end
