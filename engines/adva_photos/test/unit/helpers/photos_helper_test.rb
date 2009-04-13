require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class PhotosHelperTest < ActionView::TestCase
  include PhotosHelper
  
  def setup
    super
    @set    = Category.find_by_title('Summer')
    @photo  = Photo.find_by_title('a photo')
    @tag    = @photo.tags.find_by_name('Forest')
    @setless_photo = Photo.find_by_title('a photo without set')
    stub(self).album_set_path.returns 'album_set_path'
  end
  
  test "#collection_title, returns 'All photos' if no set or tags are given" do
    collection_title.should == 'All photos'
  end
      
  test "#collection_title, returns 'Photos about Summer' when given only a set and set title is Summer" do
    collection_title(@set).should == 'Photos about Summer'
  end

  test "#collection_title, returns 'Photos tagged Forest' when given only a tag and tag name is Forest" do
    collection_title(nil, @photo.tags).should == 'Photos tagged Forest'
  end
  
  test "#collection_title, returns 'Photos about Summer, tagged Forest' when given set and tag with those names" do
    collection_title(@set, @photo.tags).should == 'Photos about Summer, tagged Forest'
  end
  
  test "#link_to_set, links to the given set" do
    link_to_set(@set).should have_tag('a[href=?]', 'album_set_path')
  end
  
  test "#link_to_set, given the first argument is a String it uses the String as link text" do
    link_to_set('link text', @set).should =~ /link text/
  end
  
  test "#link_to_set, given the first argument is not a String it uses the set title as link text" do
    link_to_set(@set).should =~ /Summer/
  end
  
  test "#link_to_photo_sets, returns nil if the photo has no sets" do
    links_to_photo_sets(@setless_photo).should be_nil
  end
  
  test "#link_to_photo_sets, returns an array of links to the given photo's sets" do
    links_to_photo_sets(@photo).should == ["<a href=\"album_set_path\">#{@set.title}</a>"]
  end
end