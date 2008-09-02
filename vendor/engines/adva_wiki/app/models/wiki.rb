class Wiki < Section
  has_many :wikipages, :foreign_key => 'section_id'

  permissions :category => { :anonymous => :show, :moderator => [:create, :update, :destroy] },
              :wikipage => { :anonymous => :show, :user => [:create, :update, :destroy] },
              :comment  => { :anonymous => :show, :user => :create, :author => :update, :moderator => :destroy }

end