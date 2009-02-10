class Category < ActiveRecord::Base
=begin
  class Jail < Safemode::Jail
    allow :id, :title
  end
=end
  acts_as_nested_set
  has_permalink :title, :url_attribute => :permalink, :only_when_blank => true, :scope => :section_id

  belongs_to :section, :foreign_key => 'section_id'
  has_many :contents, :through => :category_assignments, :source_type => 'Content'
  has_many :category_assignments, :dependent => :delete_all

  before_save :update_path

  validates_presence_of :section, :title
  validates_uniqueness_of :permalink, :scope => :section_id
  
  protected
  
    def update_path
      if permalink_changed?
        new_path = build_path
        unless self.path == new_path
          self.path = new_path
          @paths_dirty = true
        end
      end
    end

    # FIXME this is not hooked up. same in Section. don't we need to call this anyway?
    def update_child_paths
      if @paths_dirty
        self.all_children.each do |child|
          child.path = child.build_path
          child.save
        end
        @paths_dirty = false
      end
    end

    def build_path
      self_and_ancestors.map(&:permalink).join('/')
    end
end
