steps_for :asset do
  When "the user visits admin sites assets list page" do
    raise "this step expects the variable @site to be set" unless @site
    get admin_assets_path(@site)
  end
  
  When "the user fills in the admin asset creation form with valid values" do
    attaches_file 'assets[0][uploaded_data]', RAILS_ROOT + '/public/images/rails.png'
    fills_in 'assets[0][title]', :with =>'test asset data'
    fills_in 'assets[0][tag_list]', :with => 'foo bar'
  end

  Then "the page has an admin asset creation form" do
    raise "this step expects the variable @site to be set" unless @site
    action = admin_assets_path(@site)
    response.should have_form_posting_to(action)
    @asset_count = Asset.count
  end
  
  Then "a new asset is saved" do
    raise "this step expects the variable @asset_count to be set" unless @asset_count
    (@asset_count + 1).should == Asset.count
  end

  Then "the user is redirected to admin sites assets list page" do
    request.request_uri.should =~ %r(/admin/sites/[\d]*/assets)
    response.should render_template("admin/assets/index")
  end
  
  Then "the page has a list of assets with at least one asset" do
    response.should have_tag('#assets-list .assets-row div img')
  end
end
