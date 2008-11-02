class Wiki < Section
  has_many :wikipages, :foreign_key => 'section_id'
    
  class << self
    def content_type
      'Wikipage'
    end
  end
end