steps_for :asset do
  When "the user visits admin sites assets list page" do
    raise "this step expects the variable @site to be set" unless @site
    get admin_assets_path(@site)
  end
  
  #When "the user fills in the admin asset creation form with valid values" #do
    #fills_in 'assets[][uploaded_data]', :with => 'data'
    #fills_in 'assets[][title]', :with =>'test asset data'
    #fills_in 'assets[][tag_list]', :with => 'test'
  #end

  When "the user fills in the admin asset creation form with valid values and clicks 'Upload Asset(s)' button" #do
    # TODO find a webratty way to test file uploads, and then use above method
  #  raise "this step expects the variable @site to be set" unless @site
  #  post(admin_assets_path(@site), :assets=>[{:uploaded_data => TestUploadedFile('foo'), :title => 'title', :tag_list => 'foo bar'}], :content_type => 'multipart/form-data')
  #end

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
end
