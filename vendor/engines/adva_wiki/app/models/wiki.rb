class Wiki < Section
  has_many :wikipages, :foreign_key => 'section_id'
  
  permissions :category => { :moderator => :all },
              :wikipage => { :user => [:create, :update, :destroy], :anonymous => :show },
              :comment  => { :user => :create, :author => [:update, :destroy] }

end