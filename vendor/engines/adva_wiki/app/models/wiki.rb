class Wiki < Section
  has_many :wikipages, :foreign_key => 'section_id'
  
  permissions :wikipage => { :user => [:create, :update, :delete] },
              :comment  => { :user => :create, :author => [:update, :delete] }

end