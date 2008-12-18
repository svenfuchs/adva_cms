require File.dirname(__FILE__) + '/../spec_helper'

describe AlbumsHelper do
  before :each do
    @album    = Factory :album
    @user     = Factory :user
    @set      = Factory :set, :section => @album
    @photo    = Factory :photo, :section => @album, :author => @user
    @photo.tags << Tag.new(:name => 'Forest')
  end
  
    describe "methods:" do
    describe "#collection_title" do
      it "returns 'All photos' if no set or tags are given" do
        helper.collection_title.should == 'All photos'
      end
      
      it "returns 'Photos about Summer' when given only a set and set title is Summer" do
        helper.collection_title(@set).should == 'Photos about Summer'
      end

      it "returns 'Photos tagged Forest' when given only a tag and tag name is Forest" do
        helper.collection_title(nil, @photo.tags).should == 'Photos tagged Forest'
      end
      
      it "returns 'Photos about Summer, tagged Forest' when given set and tag with those names" do
        helper.collection_title(@set, @photo.tags).should == 'Photos about Summer, tagged Forest'
      end
    end
    
    describe "#link_to_set" do
      it "links to the given set" do
        helper.link_to_set(@set).should have_tag('a[href=?]', album_set_path(@album, @set))
      end
      
      it "given the first argument is a String it uses the String as link text" do
        helper.link_to_set('link text', @set).should =~ /link text/
      end
      
      it "given the first argument is not a String it uses the set title as link text" do
        helper.link_to_set(@set).should =~ /Summer/
      end
    end
    
    describe "#link_to_photo_sets" do
      before :each do
        @photo.sets << @set
      end
      it "returns nil if the photo has no sets" do
        @photo.stub!(:sets).and_return []
        helper.links_to_photo_sets(@photo).should be_nil
      end
      
      it "returns an array of links to the given photo's sets" do
        helper.links_to_photo_sets(@photo).should == ["<a href=\"#{album_set_path(@album, @set)}\">#{@set.title}</a>"]
      end
    end
  end
end