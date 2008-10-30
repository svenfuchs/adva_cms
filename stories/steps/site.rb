factories :site

steps_for :site do
  Given "no site exists" do
    Site.delete_all
    Section.delete_all
    @site_count = 0
  end

  Given "a site" do
    @site ||= begin
      Given 'no site exists'
      create_site
    end
    @site_count = Site.count
  end

  Given "a site with no assets" do
    Given "a site"
    @site.assets.should be_empty
  end

  Given "a site with no themes" do
    Given "a site"
    raise "About to rm -rf Theme.base_dir. Set it to something else than #{Theme.base_dir}." if Theme.base_dir.blank? || ['/', RAILS_ROOT + '/themes'].include?(Theme.base_dir)
    FileUtils.rm_rf Theme.base_dir
  end

  Given "a site with the $engine spam filter and $option set to $value" do |engine, option, value|
    Given "a site"
    value = eval(value) if ['true', 'false'].include?(value)
    options = {engine.downcase.to_sym => {option.to_sym => value}}
    @site.update_attributes! :spam_options => options
  end

  Given "a site with the $engine spam filter" do |engine|
    Given "a site"
    @site.update_attributes! :spam_options => {
      :default => {:ham => "authenticated"},
      :akismet => { :key => 'key', :url => 'http://domain.org' },
      :defensio => { :key => 'key', :url => 'http://domain.org' },
      :filters => [engine]
    }
  end

  When "the user visits the admin sites list page" do
    get admin_sites_path
  end

  When "the user visits the admin site edit page" do
    get edit_admin_site_path(@site)
  end

  When "the user visits the admin site show page" do
    get admin_site_path(@site)
  end

  When "the user fills in the admin site creation form with valid values" do
    fills_in 'website name', :with => 'a new site name'
    fills_in 'website title', :with => 'a new site title'
    fills_in 'hostname', :with => 'www.example.com'
  end

  When "the user fills in the site install form with valid values" do
    fills_in 'website name', :with => 'a new site name'
    fills_in 'website title', :with => 'a new site title'
    fills_in 'title', :with => 'the root section'
  end

  Then "a new Site is created" do
    Site.count.should == @site_count + 1
    @site = Site.find :first
  end

  Then "the root section is saved" do
    @site.sections.count.should == 1
    @site.sections.root.title.should == 'the root section'
  end

  Then "the page has an admin site creation form" do
    action = "/admin/sites"
    response.should have_form_posting_to(action)
  end

  Then "the page has an admin site edit form" do
    action = admin_site_path(@site)
    response.should have_form_putting_to(action)
  end

  Then "the user is redirected the admin site show page" do
    request.request_uri.should =~ %r(/admin/sites/[\d]*)
    response.should render_template('admin/sites/show')
  end

  Then "the user is redirected the admin site edit page" do
    request.request_uri.should =~ %r(/admin/sites/[\d]*/edit)
    response.should render_template('admin/sites/edit')
  end

  Then "the user sees the install page" do
    puts response.body
    response.should render_template('admin/install/index')
  end

  Then "the page has a site install form" do
    response.should have_form_posting_to(install_path)
  end

  Then "the user sees an empty homepage" do
    request.request_uri.should == '/'
    response.should render_template('section/show')
  end
end
