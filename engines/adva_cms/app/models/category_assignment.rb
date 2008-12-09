class CategoryAssignment < ActiveRecord::Base
  belongs_to :content, :polymorphic => true
  belongs_to :category
end
