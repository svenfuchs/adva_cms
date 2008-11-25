class Calendar < Section
  has_many :events, :foreign_key => 'section_id'
    
  class << self
    def content_type
      'Calendar::Event'
    end
  end
end