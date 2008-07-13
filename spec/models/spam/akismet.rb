require File.dirname(__FILE__) + '/../../spec_helper'

describe 'Spam engines', 'the Akismet engine' do
  before :each do
    @comment = Comment.new
    @akismet = stub("akismet", :check_comment => false)
    Viking::Akismet.stub!(:new).and_return(@akismet)
    @url = 'http://www.example.org/an-article'
  end
  
  def engine
    @site.spam_engine
  end
  
  describe 'when properly configured' do
    before :each do
      @site = Site.new :spam_options => {:engine => 'Akismet', 'Akismet' => {:akismet_key => 'key', :akismet_url => 'http://domain.com'}}
    end
    
    it "is valid?" do      
      engine.valid?.should be_true
    end
  
    it "instantiates a Viking Akismet backend when calling #check_comment" do
      Viking::Akismet.should_receive(:new).and_return(@akismet)
      engine.check_comment(@url, @comment)
    end
    
    it "#check_comment returns a spam_info hash with :spam => false when the backend returned true" do
      @akismet.stub!(:check_comment).and_return true
      engine.check_comment(@url, @comment).should == {:spam => false}
    end
    
    it "#check_comment returns a spam_info hash with :spam => true when the backend returned false" do
      @akismet.stub!(:check_comment).and_return false
      engine.check_comment(@url, @comment).should == {:spam => true}
    end
  end
  
  describe 'when the akismet key is missing' do
    before :each do
      @site = Site.new :spam_options => {:engine => 'Akismet', 'Akismet' => {:akismet_url => 'http://domain.com'}}
    end
    
    it 'is not valid' do
      engine.valid?.should be_false
    end
    
    it 'raises NotConfigured when calling #check_comment' do
      lambda { engine.check_comment(@url, @comment) }.should raise_error(SpamEngine::NotConfigured)
    end
  end
  
  describe 'when the akismet url is missing' do
    before :each do
      @site = Site.new :spam_options => {:engine => 'Akismet', 'Akismet' => {:akismet_key => 'key'}}
    end
    
    it 'is not valid' do
      engine.valid?.should be_false
    end
    
    it 'raises NotConfigured when calling #check_comment' do
      lambda { engine.check_comment(@url, @comment) }.should raise_error(SpamEngine::NotConfigured)
    end
    
    it 'raises NotConfigured when calling #mark_as_ham' do
      lambda { engine.mark_as_ham(@url, @comment) }.should raise_error(SpamEngine::NotConfigured)
    end
    
    it 'raises NotConfigured when calling #mark_as_spam' do
      lambda { engine.mark_as_spam(@url, @comment) }.should raise_error(SpamEngine::NotConfigured)
    end
  end
  
  # before :each do
  #   @comment = comments(:a_comment)
  #   @comment.author = anonymouses(:an_anonymous) # wtf
  #   @comment.commentable = contents(:an_article)
  #   
  #   http = Net::HTTP.new("url")
  #   Net::HTTP.stub!(:new).and_return(http)
  #   
  #   @options  = { :permalink => "http://www.example.org/an-article", 
  #                 :user_ip => '1.1.1.1', 
  #                 :user_agent => 'the-agent', 
  #                 :referrer => 'the-referer', 
  #                 :comment_author => "anonymous", 
  #                 :comment_author_email => "anonymous@email.org", 
  #                 :comment_author_url => "http://www.example.org", 
  #                 :comment_content => "comment body" }
  # end
  # 
  # it "calls #check_comment on the Akismet Viking engine when the site's spam_option :engine is 'Akismet'" do
  #   sites(:site_1).update_attributes :spam_options => {:engine => 'Akismet', 'Akismet' => {:akismet_key => 'key', :akismet_url => 'http://domain.com'}}
  #   @comment.section.site.spam_engine.send(:akismet).should_receive(:check_comment).with(@options).and_return true
  #   @comment.check_spam('http://www.example.org/an-article', @comment)
  #   @comment.spam_info.should == {:spam => false}
  # end
end