class Test::Unit::TestCase
  def login(user)
    @user = user
    stub(@controller).current_user.returns(user)
  end

  share :no_user do
    before do 
      User.delete_all
    end
  end

  share :a_user do
    before do 
      @user = User.first
    end
  end
  
  def valid_user_params
    { :first_name      => 'first name',
      :last_name       => 'last name',
      :email           => 'email@email.org',
      :password        => 'password',
      :homepage        => 'http://homepage.org' }
  end
  
  share :valid_user_params do
    before { @params = { :user => valid_user_params } }
  end
  
  share :invalid_user_params do
    before { @params = { :user => valid_user_params.update(:first_name => '') } }
  end
  
  share :invalid_user_params do
    before { @params = { :user => valid_user_params.update(:email => '') } }
  end
  
  share :invalid_user_params do
    before { @params = { :user => valid_user_params.update(:password => '') } }
  end
  
  share :users do
    before do
      @user1 = User.find_by_name('user1')
      @user2 = User.find_by_name('user2')
      @user3 = User.find_by_name('user3')
      @user4 = User.find_by_name('user4')
    end
  end
  
end