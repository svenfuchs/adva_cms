factories :site

steps_for :plugin do  
  When "the user visits the admin plugin list page" do
    get admin_plugins_path(@site) 
  end
  
  When "the user visits the admin plugin show page for the test plugin" do
    get admin_plugin_path(@site, 'test_plugin') 
  end
  
  When "the user fills in the plugin config edit form" do
    fills_in 'string', :with => 'custom string'
    fills_in 'text', :with => 'custom text'
  end
  
  Then "the list contains all the plugins installed" do
    @site.plugins.each do |plugin|
      response.should have_text(/#{plugin.name}/)
    end
  end
  
  Then "the page shows the test plugin about info" do
    plugin = @site.plugins[:test_plugin]
    response.should have_text(/#{plugin.name}/)
    [:version, :author, :homepage, :summary, :description].each do |attr|
      response.should have_text(/#{plugin.about[attr]}/) if plugin.about[attr]
    end
  end
  
  Then "the page has a plugin config edit form" do
    response.should have_form_putting_to(admin_plugin_path(@site, 'test_plugin'))    
  end
  
  Then "the plugin's configuration is saved" do
    config = @site.plugins[:test_plugin].send(:config)
    config.reload
    config.options.should == {'string' => 'custom string', 'text' => 'custom text'}
  end
end