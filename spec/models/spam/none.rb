require File.dirname(__FILE__) + '/../../spec_helper'

describe 'Spam engines', 'the None engine' do
  before :each do
    @comment = Comment.new
    @url = 'http://www.example.org/an-article'
  end
  
  def engine
    @site.spam_engine
  end
  
  it "is valid?" do      
    engine.valid?.should be_true
  end
  
  it "#check_comment returns an empty spam_info hash" do
    engine.check_comment(@url, @comment).should == {}
  end
end