class Wiki < Section
  has_many :wikipages, :foreign_key => 'section_id'
    
  if Rails.plugin?(:adva_safemode)
    class Jail < Section::Jail
      allow :wikipages
    end
  end

  class << self
    def content_type
      'Wikipage'
    end
  end
end
