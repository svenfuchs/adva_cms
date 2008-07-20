factories :site

steps_for :site do
  When "the user goes to the admin theme list page" do
    get admin_themes_path(@site)
  end
  
  When "the user goes to the admin theme show page" do
    get admin_theme_path(@site, 'a_new_theme')
  end
  
  When "the user goes to the admin theme import page" do
    get import_admin_themes_path(@site)
  end
  
  When "the user fills in the admin theme creation form with valid values" do
    fills_in 'name', :with => 'a new theme'
    fills_in 'author', :with => 'the author'
    fills_in 'homepage', :with => 'http://homepage.org'
    fills_in 'version', :with => 'the version number'
    fills_in 'summary', :with => 'the summary'
  end
  
  When "the user fills in the admin theme file creation form with valid values" do
    fills_in 'Filename', :with => 'shared/_footer.html.erb'
    fills_in 'file[data]', :with => 'this is the new theme template' # + "some random text #{rand}" * 1024
  end
  
  When "the user fills in the form with valid values" do
    attaches_file 'theme[file]', RAILS_ROOT + "/tmp/stories/downloads/theme.zip"    
  end
  
  When "the user downloads the theme" do
    clicks_link 'Download'
    filename = RAILS_ROOT + "/tmp/stories/downloads/theme.zip"
    FileUtils.mkdir_p File.dirname(filename)
    File.open(filename, 'wb+') {|f| f.write(response.body) }
  end
  
  Then "the user sees the admin theme creation page" do
    request.request_uri.should == new_admin_theme_path(@site)
    response.should render_template('admin/themes/new')
  end
  
  Then "the user sees the admin theme show page" do
    request.request_uri.should == admin_theme_path(@site, 'a_new_theme')
    response.should render_template('admin/themes/show')
  end
  
  Then "the page has an admin theme creation form" do
    action = admin_themes_path(@site)
    response.should have_form_posting_to(action)
  end
  
  Then "the page has an admin theme edit form" do
    action = admin_theme_path(@site, @theme)
    response.should have_form_putting_to(action)
  end

  Then "the page has an admin theme file creation form" do
    action = admin_theme_files_path(@site, 'a_new_theme')
    response.should have_form_posting_to(action)
  end
  
  Then "the page has a theme import form" do
    action = import_admin_themes_path(@site)
    response.should have_form_posting_to(action)
  end
  
  Then "the page lists the filename of the new theme template" do
    response.should have_text(%r(templates/shared/_footer.html.erb))
  end
  
  Then "a new theme is saved" do
    @theme = Theme.find('a_new_theme', "site-#{@site.id}")
    @theme.should_not be_nil
  end
  
  Then "the theme was updated" do
    @theme = Theme.find('a_new_theme', "site-#{@site.id}")
    @theme.should_not be_nil
    @theme.author.should == 'the updated author'
  end
  
  Then "the theme was deleted" do
    @theme = Theme.find('a_new_theme')
    @theme.should be_nil
  end
  
  Then "the theme was imported" do
    @theme = Theme.find('a_new_theme', "site-#{@site.id}")
    @theme.should_not be_nil
    @theme.name.should == 'a new theme'
  end
  
  Then "the theme is selected" do
    @site.reload
    @site.theme_names.should include('a_new_theme')
  end
  
  Then "the user is redirected to the admin theme list page" do
    request.request_uri.should =~ %r(/admin/sites/[\d]*/themes$)
    response.should render_template("admin/themes/index")
  end
  
  Then "the user is redirected to the admin theme show page" do
    request.request_uri.should =~ %r(/admin/sites/[\d]*/themes/[\w]*$)
    response.should render_template("admin/themes/show")
  end
  
  Then "the user is redirected to the admin theme_files show page" do
    request.request_uri.should =~ %r(/admin/sites/[\d]*/themes/[\w]*/files/[\w-]*$)
    response.should render_template("admin/theme_files/show")
  end
end