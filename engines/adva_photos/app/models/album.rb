class Album < Section
  has_many :photos, :foreign_key => 'section_id', :dependent => :destroy
  
  def self.content_type
    'Photo'
  end
end