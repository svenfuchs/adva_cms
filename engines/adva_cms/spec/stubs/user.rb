define User do
  has_many :roles

  methods  :has_role? => false,
           :anonymous? => false,
           :registered? => true,
           :is_site_member? => true,
           :update_attributes => true,
           :destroy => true,
           :save! => true,
           :verify! => nil,
           :assign_token => 'token',
           :email= => nil,
           :valid? => true,
           :track_method_calls => nil

  instance :user,
           :id => 1,
           :first_name => 'John',
           :last_name => 'Doe',
           :name => 'John Doe',
           :email => 'foo@bar.baz',
           :homepage => 'http://foo.bar.baz',
           :password => 'password',
           :created_at => Time.now,
           :updated_at => Time.now,
           :deleted_at => nil
end

