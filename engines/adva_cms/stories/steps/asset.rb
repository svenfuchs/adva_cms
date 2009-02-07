steps_for :asset do
  Given "a site with an asset" # do
  #  Given "a site"
  #end

  When "the user visits admin sites assets list page" do
    raise "this step expects the variable @site to be set" unless @site
    get admin_assets_path(@site)
  end

  When "the user fills in the admin asset creation form with valid values" do
    attach_file 'assets[0][uploaded_data]', RAILS_ROOT + '/public/images/rails.test.png'
    fill_in 'assets[0][title]', :with => 'title'
    fill_in 'assets[0][tag_list]', :with => 'foo bar'
  end

  When "the user fills in the admin asset edit form" do
    fill_in 'asset[title]', :with => 'updated title'
  end

  When "the user adds an asset to the bucket" do
    post "/admin/sites/#{@site.id}/assets/bucket?asset_id=#{@asset.id}"
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
    @asset = Asset.find :last
  end

  Then "the user is redirected to admin sites assets list page" do
    request.request_uri.should =~ %r(/admin/sites/[\d]*/assets)
    response.should render_template("admin/assets/index")
  end

  Then "the page has a list of assets with at least one asset" do
    response.should have_tag('#assets_list .assets_row div img')
  end

  Then "the page has an admin asset edit form" do
    response.should have_form_putting_to(admin_asset_path(@site, @asset))
  end

  Then "the asset is updated" do
    @asset.reload
    @asset.title = 'updated title'
  end

  Then "the asset is deleted" do
    Asset.exists?(@asset.id).should be_false
  end

  Then "the asset is added to the bucket" do
    session[:bucket].keys.should include(@asset.id)
  end

  Then "the asset immediately shows up on the page" do
    assert_select_rjs :insert, :bottom, 'Element' do
      assert_select 'li a[href=?]', @asset.public_filename
    end
    response.should_not have_text(%r(<html.*>)) # no layout
  end
end
