class Test::Unit::TestCase
  share :no_site do
    before { Site.delete_all }
  end
  
  share :an_empty_site do
    before { @site = Site.make }
  end
  
  share :valid_install_params do
    before do
      @params = { :site    => {:name => 'site name'},
                  :section => {:type => 'Section', :title => 'section title'},
                  :user    => {:email => 'admin@admin.org', :password => 'password'} }
    end
  end
  
  share :invalid_install_params do
    before do
      # should be something like:
      # @params = Site.install_params_missing(:site => :name)
      @params = { :site    => { },
                  :section => {:type => 'Section', :title => 'section title'},
                  :user    => {:email => 'admin@admin.org', :password => 'password'} }
    end
  end

  share :invalid_install_params do
    before do
      @params = { :site    => {:name => 'site name'},
                  :section => {:type => 'Section'},
                  :user    => {:email => 'admin@admin.org', :password => 'password'} }
    end
  end

  share :invalid_install_params do
    before do
      @params = { :site    => {:name => 'site name'},
                  :section => {:type => 'Section'},
                  :user    => {:password => 'password'} }
    end
  end
end