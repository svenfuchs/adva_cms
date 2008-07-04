factories :site

steps_for :site do
  Given "no site exists" do
    Site.delete_all
  end
  
  Given "a site" do
    Given "no site exists"
    @site = create_site
    @site_count = Site.count
  end
  
  When "the user visits the sites list page" do
    get "/admin/sites"
  end
  
  When "the user visits the site's edit page" do
    get "/admin/sites/#{@site.to_param}/edit"
  end
  
  When "the user fills in the site creation form with valid values" do
    fills_in 'website name', :with => 'a new site name'
    fills_in 'website title', :with => 'a new site title'
    fills_in 'hostname', :with => 'www.example.com'
  end
  
  Then "a new Site is created" do
    Site.count.should == @site_count + 1
  end
  
  Then "the page has a site creation form" do
    action = "/admin/sites"
    response.should have_tag('form[action=?][method=?]', action, 'post')
  end
  
  Then "the page has a site edit form" do
    @section = Section.find :first
    action = "/admin/sites/#{@site.to_param}"
    response.should have_tag('form[action=?]', action) do |form|
      form.should have_tag('input[name=?][value=?]', '_method', 'put')
    end
  end
  
  Then "the user is redirected the site's show page" do
    request.request_uri.should =~ %r(/admin/sites/[\d]*)
    response.should render_template('admin/sites/show')
  end
  
  Then "the user is redirected the site's edit page" do
    request.request_uri.should =~ %r(/admin/sites/[\d]*/edit)
    response.should render_template('admin/sites/edit')
  end
end