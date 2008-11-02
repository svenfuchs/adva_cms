scenario :site_with_assets do
  stub_scenario :empty_site

  @asset = stub_asset
  @assets = stub_assets
    
  Asset.stub!(:find).and_return @asset
end
