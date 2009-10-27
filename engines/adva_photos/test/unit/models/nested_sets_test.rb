require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class NestedSetsTest < ActiveSupport::TestCase
  def setup
    super
    @set = Category.find_by_title('Summer')
    @sub_set = Category.find_by_title('A Subset')
    @sub_set_photo = Photo.create!(:title => 'a subset photo',
                                  :data_content_type => 'image/jpeg',
                                  :data_file_name    => 'test.png',
                                  :author  => User.first,
                                  :section => @sub_set.section,
                                  :published_at => Time.parse('2008-01-01 12:00:00') )
    
    @sub_set_photo.sets << @sub_set
    @photos = @set.photos << @sub_set_photo
  end
  
  test 'all_contents returns a scope of all the photos of set and its descendants' do
    assert_equal @photos.sort_by {|p| p.id}, @set.all_contents.sort_by {|c| c.id}
    assert_equal [@sub_set_photo], @sub_set.all_contents
  end
end