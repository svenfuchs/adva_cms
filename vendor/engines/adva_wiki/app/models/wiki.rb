class Wiki < Section
  has_many :wikipages, :foreign_key => 'section_id'
  
  permissions :wikipage => { :user => [:create, :update, :destroy], :anonymous => :show },
              :comment  => { :user => :create, :author => [:update, :destroy] }

end