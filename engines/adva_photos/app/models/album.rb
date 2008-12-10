class Album < Section
  has_many :photos
  
  def self.content_type
    'Photo'
  end
end