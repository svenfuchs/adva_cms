class Test::Unit::TestCase
  share :multi_sites_enabled do
    before { Site.multi_sites_enabled = true }
  end
  
  share :no_site do
    before { Site.delete_all }
  end
  
  share :an_empty_site do
    before { @site = Site.make }
  end
  
  share :a_cached_page do
    before { @cached_page = CachedPage.make :site_id => @site.id, :section_id => @section.id }
  end
  
  share :valid_site_params do
    before do
      @params = { :site    => {:name => 'site name'},
                  :section => {:type => 'Section', :title => 'section title'} }
    end
  end
  
  share :invalid_site_params do
    before do
      @params = { :site    => {:name => ''},
                  :section => {:type => 'Section', :title => 'section title'} }
    end
  end
  
  # FIXME
  # these aren't invalid because the controller defaults the section title to 'Home'
  # share :invalid_site_params do
  #   before do
  #     @params = { :site    => {:name => 'site name'},
  #                 :section => {:type => 'Section', :title => ''} }
  #   end
  # end
  
  share :valid_install_params do
    before do
      @params = { :site    => {:name => 'site name'},
                  :section => {:type => 'Section', :title => 'section title'},
                  :user    => {:email => 'admin@admin.org', :password => 'password'} }
    end
  end
  
  share :invalid_install_params do
    before do
      # FIXME should be something like:
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