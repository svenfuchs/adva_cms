scenario :site_with_assets do
  scenario :empty_site

  @asset = stub_asset
  @assets = stub_assets

  Asset.stub!(:find).and_return @asset
end
