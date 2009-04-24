class Album < Section
  has_many :photos, :foreign_key => 'section_id', :dependent => :destroy
  has_many :sets, :class_name => 'Category', :foreign_key => 'section_id', :dependent => :destroy, :order => 'lft' do
    def roots
      find :all, :conditions => {:parent_id => nil}, :order => 'lft'
    end

    def update_paths!
      paths = Hash[*roots.map { |r| 
        r.self_and_descendants.map { |n| [n.id, { 'path' => n.send(:build_path) }] } }.flatten]
      update paths.keys, paths.values
    end
  end
  has_option :photos_per_page, :default => 25
  
  has_filter :tagged, :categorized,
             :text  => { :attributes => :title },
             :state => { :states => [:published, :unpublished] }
  
  def self.content_type
    'Photo'
  end
end