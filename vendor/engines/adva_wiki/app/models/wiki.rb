class Wiki < Section
  has_many :wikipages, :foreign_key => 'section_id'
end