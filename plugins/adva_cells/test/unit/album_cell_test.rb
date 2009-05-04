require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class AlbumCellTest < ActiveSupport::TestCase
  def setup
    super
    @album        = Album.first
    @first_photo  = @album.photos(:conditions => "published_at IS NOT NULL").first
    @second_photo = Photo.find(@album.photos.second.id, :conditions => "published_at IS NOT NULL")
    @controller   = CellTestController.new
    @cell         = AlbumCell.new(@controller)
  end
  
  test "#single sets the album from options[:section] if available" do
    @cell.instance_variable_set(:@opts, {:section => @album.id})
    @cell.single
    @cell.instance_variable_get(:@album).should == @album
  end
  
  test "#single sets the photo if album and photo_id is set and photo is published" do
    @cell.instance_variable_set(:@opts, {:section => @album.id, :photo_id => @second_photo.id})
    @cell.single
    @cell.instance_variable_get(:@photo).should == @second_photo
  end
  
  test "#single sets the photo as first published album photo if only album is set" do
    @cell.instance_variable_set(:@opts, {:section => @album.id})
    @cell.single
    @cell.instance_variable_get(:@photo).should == @first_photo
  end
  
  test "#single sets the photo if photo_id is set and photo is published" do
    @cell.instance_variable_set(:@opts, {:photo_id => @first_photo.id})
    @cell.single
    @cell.instance_variable_get(:@photo).should == @first_photo
  end
  
  # FIXME test the cached_references
  # FIXME test the has_state option

  # FIXME should we just set the photo to nil or raise active_record::record_not_found like it is
  # doing now?
  #
  # test "#single does not set the photo if photo_id is set and photo is unpublished" do
  #   @cell.instance_variable_set(:@opts, {:photo_id => @album.photos.last.id})
  #   @cell.single
  #   @cell.instance_variable_get(:@photo).should == nil
  # end
end