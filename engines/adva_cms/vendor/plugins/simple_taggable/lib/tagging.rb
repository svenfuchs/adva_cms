class Tagging < ActiveRecord::Base #:nodoc:
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true
  
  def after_destroy
    tag.destroy if Tag.destroy_unused && tag.taggings.count.zero?
  end
end
