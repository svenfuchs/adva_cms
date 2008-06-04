class Wiki < Section
  has_many :wikipages, :foreign_key => 'section_id'
  
  self.default_required_roles = { :manage_wikipages => :user, 
                                  :manage_categories => :admin }

end