class Album < Section
  has_many :photos, :foreign_key => 'section_id', :conditions => 'parent_id is null', :dependent => :destroy
  has_option :photos_per_page, :default => 25
  
  def self.content_type
    'Photo'
  end
end