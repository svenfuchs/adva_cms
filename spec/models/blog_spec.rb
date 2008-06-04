require File.dirname(__FILE__) + '/../spec_helper'

describe Blog do
  fixtures :sections
  
  before :each do
    @blog = sections(:blog)
  end
  
  it "should have an option :articles_per_page" do
    lambda{ @blog.articles_per_page }.should_not raise_error
  end
  
  it "should serialize the option :articles_per_page to the database" do
    @blog.instance_variable_set :@options, nil
    save_and_reload @blog
    @blog.articles_per_page = 20
    save_and_reload @blog
    @blog.articles_per_page.should == 20
  end
  
  def save_and_reload(record)
    record.save
    record.reload
  end
end