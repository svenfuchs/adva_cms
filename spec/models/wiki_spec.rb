require File.dirname(__FILE__) + '/../spec_helper'

describe Wiki do
  before :each do
    @wiki = Wiki.new
  end
  
  it "is a kind of Section" do
    @wiki.should be_kind_of(Section)
  end

  it "has many wikipages" do
    @wiki.should have_many(:wikipages)
  end

  it "has default permissions for wikipages and comments" # TODO what about categories?
end