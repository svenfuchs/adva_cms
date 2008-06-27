class Wiki < Section
  has_many :wikipages, :foreign_key => 'section_id'
  
  permissions :wikipage => { :user => [:create, :update, :destroy] },
              :comment  => { :user => :create, :author => [:update, :destroy] }

end