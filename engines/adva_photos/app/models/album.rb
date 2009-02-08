class Album < Section
  has_many :photos, :foreign_key => 'section_id', :dependent => :destroy
  has_many :sets, :class_name => 'Category', :foreign_key => 'section_id', :dependent => :destroy, :order => 'lft' do
    def roots
      find :all, :conditions => {:parent_id => nil}, :order => 'lft'
    end
  end
  has_option :photos_per_page, :default => 25
  
  def self.content_type
    'Photo'
  end
end