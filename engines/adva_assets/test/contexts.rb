class Test::Unit::TestCase
  def valid_asset_params
    { :data     => File.new("#{File.dirname(__FILE__)}/fixtures/rails.png"),
      :title    => 'the-asset-title',
      :tag_list => 'foo bar' }
  end

  share :valid_asset_params do
    before do
      @params = { :assets => [valid_asset_params] }
    end
  end
  
  share :invalid_asset_params do
    before do
      @params = { :assets => [valid_asset_params.update(:site_id => 0, :title => '', :data => nil)] }
    end
  end

  share :an_asset do
    before do 
      @asset = @site.assets.build([valid_asset_params]).first
      @asset.save!
    end
  end
end