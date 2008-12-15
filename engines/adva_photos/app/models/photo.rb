class Photo < ActiveRecord::Base
  acts_as_versioned     :if_changed => [:title], :limit => 5
  non_versioned_columns << 'cached_tag_list'
  acts_as_role_context  :parent => Section
  acts_as_taggable
  
  belongs_to_author
  belongs_to        :section
  has_many_comments :polymorphic => true
  has_permalink     :title, :scope => :section_id
  
  validates_presence_of   :title
  validates_uniqueness_of :permalink, :scope => :section_id
end