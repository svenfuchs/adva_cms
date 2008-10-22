define Anonymous do
  methods  :has_role? => false,
           :anonymous? => true,
           :registered? => false,
           :update_attributes => true,
           :destroy => true,
           :valid? => true

  instance :user,
           :id => 1,
           :first_name => 'John',
           :last_name => 'Doe',
           :name => 'John Doe',
           :email => 'foo@bar.baz',
           :homepage => 'http://foo.bar.baz'
end

define User do
  has_many :roles

  methods  :has_role? => false,
           :has_exact_role? => false,
           :anonymous? => false,
           :registered? => true,
           :is_site_member? => true,
           :update_attributes => true,
           :destroy => true,
           :save! => true,
           :verify! => nil,
           :assign_token => 'token',
           :email= => nil,
           :valid? => true

  instance :user,
           :id => 1,
           :first_name => 'John',
           :last_name => 'Doe',
           :name => 'John Doe',
           :email => 'foo@bar.baz',
           :homepage => 'http://foo.bar.baz',
           :login => 'login',
           :password => 'password',
           :password_confirmation => 'password',
           :created_at => Time.now,
           :updated_at => Time.now,
           :deleted_at => nil
end

