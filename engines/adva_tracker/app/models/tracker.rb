class Tracker < Section  
  has_many :projects, :foreign_key => "section_id"

  class << self
    def content_type
      'Tracker'
    end
  end
end
