require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class AssetWithPaperclipTest < ActiveSupport::TestCase
  include AssetsTestHelper

  def setup
    super
    @site = Site.first
  end
  
  test "destroys the attachment" do
    asset = create_image_asset
    asset.destroy
    asset.path.should_not be_file
  end

  test "creates a valid asset" do
    asset = create_image_asset
    asset.should be_valid
    asset.path.should be_file
  end

  test "creates medium, thumb and tiny variants if ImageMagick is installed" do
    asset = create_image_asset
    [:medium, :thumb, :tiny].each do |style|
      asset.path(style).should be_file
    end
  end unless `which convert`.blank?
end

class AssetTest < ActiveSupport::TestCase
  include AssetsTestHelper

  def setup
    super
    @site = Site.first
    stub_paperclip_post_processing!
  end

  test "acts as taggable" do
    Asset.should act_as_taggable
  end

  # ASSOCIATIONS

  test "belongs to a site" do
    Asset.should belong_to(:site)
  end

  test "has_many contents" do
    Asset.should have_many(:contents)
  end

  test "has_many asset_assignments" do
    Asset.should have_many(:asset_assignments)
  end

  # VALIDATIONS

  test "validates the presence of site_id" do
    Asset.should validate_presence_of(:site_id)
  end

  test "does not change the filename if the file does not exist" do
    create_image_asset.path.should == "#{Asset.root_dir}/sites/site-#{@site.id}/assets/rails.png"
  end

  test "appends an integer to basename to ensure a unique filename if the file exists" do
    dirname = "#{Asset.root_dir}/sites/site-#{@site.id}/assets"
    FileUtils.mkdir_p dirname
    File.cp image_fixture.path, "#{dirname}/rails.png"
    create_image_asset.path.should == "#{dirname}/rails.1.png"
    create_image_asset.path.should == "#{dirname}/rails.2.png"
  end

  # NAMED SCOPES

  test "Asset.images returns images" do
    image = create_image_asset

    images = Asset.images
    images.size.should == 1
    images.should include(image)
  end

  test "Asset.videos returns videos" do
    video = create_video_asset

    videos = Asset.videos
    videos.size.should == 1
    videos.should include(video)
  end

  test "Asset.audios returns audios" do
    audio = create_audio_asset

    audios = Asset.audios
    audios.size.should == 1
    audios.should include(audio)
  end

  test "Asset.others returns other assets" do
    pdf = create_pdf_asset
    text = create_text_asset

    others = Asset.others
    others.size.should == 2
    others.should include(pdf)
    others.should include(text)
  end

  test "Asset.is_media_type with paginate returns assets matching the queried content types and paginate options" do
    image = create_image_asset
    video = create_video_asset
    audio = create_audio_asset
    create_pdf_asset
    create_text_asset

    assets = Asset.is_media_type(['image', 'video', 'audio']).paginate(:order => :id, :per_page => 1, :page => 1)
    assets.size.should == 1
    assets.total_entries.should == 3
    assets.should include(image)

    assets = Asset.is_media_type(['image', 'video', 'audio']).paginate(:order => :id, :per_page => 1, :page => 2)
    assets.size.should == 1
    assets.total_entries.should == 3
    assets.should include(video)
  end

  # test "Asset.filter_by filtering works" do
  #   image = create_image_asset :title => 'that image'
  #   create_text_asset
  # 
  #   assets = Asset.filter_by(:is, :title, 'that image')
  #   assets.size.should == 1
  #   assets.should include(image)
  # 
  #   assets = Asset.filter_by([:is, :title, 'that image'], [:is_media_type, :image])
  #   assets.size.should == 1
  #   assets.should include(image)
  # end

  # CLASS METHODS

  test "image? returns true for image content types" do
    ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png', 'image/jpg'].each do |type|
      Asset.image?(type).should be_true
    end
  end

  test "image? returns false for video, audio, pdf and other content types" do
    ['video/mpeg', 'audio/mpeg', 'application/pdf', 'text/plain'].each do |type|
      Asset.image?(type).should be_false
    end
  end

  test "video? returns true for video content types" do
    ['video/mpeg', 'application/x-shockwave-flash'].each do |type|
      Asset.video?(type).should be_true
    end
  end

  test "video? returns false for image, audio, pdf and other content types" do
    ['image/jpeg', 'audio/mpeg', 'application/pdf', 'text/plain'].each do |type|
      Asset.video?(type).should be_false
    end
  end

  test "audio? returns true for audio content types" do
    ['audio/mpeg', 'application/ogg'].each do |type|
      Asset.audio?(type).should be_true
    end
  end

  test "audio? returns false for image, video, pdf and other content types" do
    ['image/jpeg', 'video/mpeg', 'application/pdf', 'text/plain'].each do |type|
      Asset.audio?(type).should be_false
    end
  end

  test "pdf? returns true for pdf content types" do
    Asset.pdf?('application/pdf').should be_true
  end

  test "pdf? returns false for image, audio, video and other content types" do
    ['image/jpeg', 'audio/mpeg', 'video/mpeg', 'text/plain'].each do |type|
      Asset.pdf?(type).should be_false
    end
  end

  test "other? returns true for content types other than images, videos, audios and pdfs" do
    ['text/plain', 'text/html'].each do |type|
      Asset.other?(type).should be_true
    end
  end

  test "other? returns false for image, video, audio and pdf content types" do
    ['image/jpeg', 'video/mpeg', 'audio/mpeg', 'application/pdf'].each do |type|
      Asset.other?(type).should be_false
    end
  end

  # INSTANCE_METHODS

  test "filename returns original data_file_name for :original style" do
    asset = Asset.new :data_file_name => 'rails.png'
    asset.filename.should == 'rails.png'
  end

  test "filename inserts the style between basename and extension for other styles" do
    asset = Asset.new :data_file_name => 'rails.png'
    asset.filename(:thumb).should == 'rails.thumb.png'
  end

  test "image? returns true for an image asset" do
    create_image_asset.image?.should be_true
  end
end