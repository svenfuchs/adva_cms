class Category < ActiveRecord::Base
  class Jail < Safemode::Jail
    allow :id, :title
  end  

  acts_as_nested_set
  has_permalink :title, :scope => :section_id
  
  belongs_to :section, :foreign_key => 'section_id'  
  has_many :contents, :through => :category_assignments
  has_many :category_assignments, :dependent => :delete_all

  before_validation :set_path
  
  validates_presence_of :section, :title
  validates_uniqueness_of :permalink, :scope => :section_id
  
  class << self
    def find_all_by_host(host)
      find(:all, :conditions => ["categories.path <> '' AND sites.host = ?", host], :include => {:section => :site})
    end
  end
  
  def set_path    
    new_path = build_path
    unless self.path == new_path
      self.path = new_path
      @paths_dirty = true
    end
  end
  
  def update_child_paths
    return unless @paths_dirty
    self.all_children.each do |child|
      child.path = child.build_path
      child.save
    end
    @paths_dirty = false
  end
  
  def build_path
    self_and_ancestors.map(&:permalink).join('/')
  end
end
