class Test::Unit::TestCase
  def valid_asset_params
    { :uploaded_data  => fixture_file_upload('/uploads/rails.png', 'image/png', :binary),
      :title          => 'the-asset-title',
      :tag_list       => 'foo bar' }
  end

  share :valid_asset_params do
    before do
      @params = { :assets => { '0' => valid_asset_params } }
    end
  end
  
  share :invalid_asset_params do
    before do
      @params = { :assets => { '0' => valid_asset_params.update(:site_id => 0, :title => '', :uploaded_data => '') } }
    end
  end

  share :an_asset do
    before do 
      @asset = @site.assets.build([valid_asset_params]).first
      @asset.save!
    end
  end
end