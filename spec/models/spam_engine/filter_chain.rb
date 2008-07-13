require File.dirname(__FILE__) + '/../../spec_helper'

describe 'SpamEngine:', 'the FilterChain' do
  before :each do
    options = {
      :default => {:approve_all => false, :priority => 1},
      :akismet => {:key => 'akismet key', :url => 'akismet url', :priority => 2},
      :defensio => {:key => 'defensio key', :url => 'defensio url', :priority => 3}
    }
    @chain = SpamEngine::FilterChain.assemble options
    @default, @akismet, @defensio = *@chain   
    
    @comment = Comment.new
    @context = {:url => 'http://domain.org/an-article'} 
  end
  
  it "when called #assemble returns a filter chain with filters assembled" do
    @default.should be_instance_of(SpamEngine::Filter::Default)
    @default.options.should == {:approve_all => false, :priority => 1}
    
    @akismet.should be_instance_of(SpamEngine::Filter::Akismet)
    @akismet.options.should == {:key => 'akismet key', :url => 'akismet url', :priority => 2}
    
    @defensio.should be_instance_of(SpamEngine::Filter::Defensio)
    @defensio.options.should == {:key => 'defensio key', :url => 'defensio url', :priority => 3}
  end
  
  it "when called #check_comment calls #check_comment on the filters in the correct order" do
    @default.should_receive(:check_comment) do
      @akismet.should_receive(:check_comment) do
        @defensio.should_receive(:check_comment)
      end
    end
    
    @comment.stub!(:add_spam_report)
    @chain.check_comment(@comment, @context)
  end
end

