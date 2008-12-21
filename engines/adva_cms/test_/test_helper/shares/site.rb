class Test::Unit::TestCase
  share :multi_sites_enabled do
    before { Site.multi_sites_enabled = true }
  end
  
  share :no_site do
    before { Site.delete_all }
  end
  
  share :a_site do
    before { @site = Site.make }
  end
  
  share :a_cached_page do
    before { @cached_page = CachedPage.make :site_id => @site.id, :section_id => @section.id }
  end
  
  def valid_site_params
    { :site    => {:name => 'site name'},
      :section => {:type => 'Section', :title => 'section title'} }
  end
  
  def valid_install_params
    valid_site_params.merge :user => {:email => 'admin@admin.org', :password => 'password'}
  end
  
  share :valid_site_params do
    before do
      @params = valid_site_params
    end
  end
  
  share :invalid_site_params do
    before do
      @params = valid_site_params
      @params[:site][:name] = ''
    end
  end
  
  # FIXME
  # these aren't invalid because the controller defaults the section title to 'Home'
  # share :invalid_site_params do
  #   before do
  #     @params = valid_site_params
  #     @params[:section][:title] = ''
  #   end
  # end
  
  share :valid_install_params do
    before do
      @params = valid_install_params
    end
  end
  
  share :invalid_install_params do
    before do
      # FIXME should be something like:
      # @params = Site.install_params_missing(:site => :name)
      @params = valid_install_params
      @params[:site] = {}
    end
  end

  share :invalid_install_params do
    before do
      @params = valid_install_params
      @params[:section][:title] = ''
    end
  end
  
  # FIXME these are not invalid?
  # share :invalid_install_params do
  #   before do
  #     @params = valid_install_params
  #     @params[:user][:email] = ''
  #   end
  # end
end