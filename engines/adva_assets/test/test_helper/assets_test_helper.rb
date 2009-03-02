module AssetsTestHelper
  def image_fixture
    File.new "#{File.dirname(__FILE__)}/../fixtures/rails.png"
  end

  def video_fixture
    File.new "#{File.dirname(__FILE__)}/../fixtures/TextOnly.mov"
  end

  def audio_fixture
    File.new "#{File.dirname(__FILE__)}/../fixtures/car_door.wav"
  end

  def pdf_fixture
    File.new "#{File.dirname(__FILE__)}/../fixtures/confidential.pdf"
  end

  def text_fixture
    File.new "#{File.dirname(__FILE__)}/../fixtures/plain.txt"
  end

  def create_image_asset(attributes = {})
    Asset.create! attributes.merge(:site => @site, :data => image_fixture)
  end

  def create_video_asset(attributes = {})
    Asset.create! attributes.merge(:site => @site, :data => video_fixture)
  end

  def create_audio_asset(attributes = {})
    Asset.create! attributes.merge(:site => @site, :data => audio_fixture)
  end

  def create_pdf_asset(attributes = {})
    Asset.create! attributes.merge(:site => @site, :data => pdf_fixture)
  end

  def create_text_asset(attributes = {})
    Asset.create! attributes.merge(:site => @site, :data => text_fixture)
  end
end