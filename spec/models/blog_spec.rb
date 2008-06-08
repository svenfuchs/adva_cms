require File.dirname(__FILE__) + '/../spec_helper'

describe Blog do
  before :each do
    @blog = Blog.new
  end
  
  it "is a kind of Section" do
    @blog.should be_kind_of(Section)
  end
  
  it "#monthly_counts returns a hash with months (dates) as keys and article counts as values"
end