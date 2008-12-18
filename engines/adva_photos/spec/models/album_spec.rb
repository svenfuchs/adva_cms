require File.dirname(__FILE__) + '/../spec_helper'

describe Album do
  before :each do
    @album = Album.new
  end
  
  it "is kind of a Section" do
    @album.should be_kind_of(Section)
  end
  
  describe "associations" do
    it "has many photos" do
      @album.should have_many(:photos)
    end

    it "has many sets" do
      @album.should have_many(:sets)
    end

    describe "the sets association" do
      it "#roots returns all sets that do not have a parent category" do
        @album.sets.should_receive(:find).with(:all, hash_including(:conditions => {:parent_id => nil}))
        @album.sets.roots
      end
    end
  end
  
  describe "methods" do
    describe ".content_type" do
      it "returns Photo as the type name of the content" do
        Album.content_type.should == 'Photo'
      end
    end
  end
end