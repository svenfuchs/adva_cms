require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class AlbumTest < ActiveSupport::TestCase
  def setup
    super
    @album = Album.first
    @summer = @album.sets.find_by_title('Summer')
    @empty  = @album.sets.find_by_title('Empty')
    @root_sets = [@summer, @empty]
  end
  
  test "is kind of a Section" do
    @album.should be_kind_of(Section)
  end
  
  # Associations
  
  test "has many photos" do
    @album.should have_many(:photos)
  end

  test "has many sets" do
    @album.should have_many(:sets)
  end
  
  test "the sets association, #roots returns all sets that do not have a parent category" do
    @album.sets.roots.should == @root_sets
  end
  
  # Class methods
  
  test "#content_type, returns Photo as the type name of the content" do
    Album.content_type.should == 'Photo'
  end
end