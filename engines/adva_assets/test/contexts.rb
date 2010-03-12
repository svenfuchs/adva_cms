class Test::Unit::TestCase
  def valid_asset_params
    { :title    => 'the-asset-title', :tag_list => 'foo bar' }
  end

  share :valid_image_asset do
    before do
      @params = { :assets => [valid_asset_params.merge(:data => File.new("#{File.dirname(__FILE__)}/fixtures/rails.png"))] }
    end
  end

  share :valid_pdf_asset do
    before do
      @params = { :assets => [valid_asset_params.merge(:data => File.new("#{File.dirname(__FILE__)}/fixtures/confidential.pdf"))] }
    end
  end

  share :valid_text_asset do
    before do
      @params = { :assets => [valid_asset_params.merge(:data => File.new("#{File.dirname(__FILE__)}/fixtures/plain.txt"))] }
    end
  end

  share :valid_audio_asset do
    before do
      @params = { :assets => [valid_asset_params.merge(:data => File.new("#{File.dirname(__FILE__)}/fixtures/car_door.wav"))] }
    end
  end

  share :valid_video_asset do
    before do
      @params = { :assets => [valid_asset_params.merge(:data => File.new("#{File.dirname(__FILE__)}/fixtures/TextOnly.mov"))] }
    end
  end

  share :invalid_asset_params do
    before do
      @params = { :assets => [valid_asset_params.update(:site_id => 0, :title => '', :data => nil)] }
    end
  end

  share :an_asset do
    before do 
      @asset = @site.assets.build([valid_asset_params.merge(:data => File.new("#{File.dirname(__FILE__)}/fixtures/rails.png"))]).first
      @asset.save!
    end
  end
end