require File.dirname(__FILE__) + '/../spec_helper'

describe Album do
  before :each do
    @album = Album.new
  end
  
  it "is kind of a Section" do
    @album.should be_kind_of(Section)
  end
end