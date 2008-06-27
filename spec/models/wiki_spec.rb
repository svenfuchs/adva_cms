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

  it "has default permissions for wikipages and comments" do # TODO what about categories?
    Wiki.default_permissions.should == 
      { :wikipage => { :update => :user, :create => :user, :destroy => :user }, 
        :comment => { :update => :author, :destroy => :author, :create => :user }}
  end
end