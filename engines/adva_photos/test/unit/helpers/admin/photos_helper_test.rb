require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper.rb')

class PhotosHelperTest < ActiveSupport::TestCase
  include Admin::PhotosHelper
  
  def setup
    super
    @album = Album.find_by_permalink('an-album')
    @photo = @album.photos.first
    @site = @album.site
  end
  
  test "#label_text_for_photo, returns 'Choose a photo' string if photo is a new record" do
    label_text_for_photo(Photo.new).should == 'Choose a photo'
  end

  test "#label_text_for_photo, returns 'Replace the photo' string if photo is an existing record" do
    label_text_for_photo(@photo).should == 'Replace the photo'
  end
end