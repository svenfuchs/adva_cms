require File.dirname(__FILE__) + '/../../spec_helper'

describe 'Spam engines', 'the Defensio engine' do
  before :each do
    article = Article.new :published_at => Time.now
    @comment = Comment.new :commentable => article
    @defensio = stub("defensio", :check_comment => false)
    Viking::Defensio.stub!(:new).and_return(@defensio)
    @url = 'http://www.example.org/an-article'
  end
  
  def engine
    @site.spam_engine
  end
  
  describe 'when properly configured' do
    before :each do
      @site = Site.new :spam_options => {:engine => 'Defensio', 'Defensio' => {:defensio_key => 'key', :defensio_url => 'http://domain.com'}}
    end
    
    it "is valid?" do      
      engine.valid?.should be_true
    end
  
    it "instantiates a Viking Defensio backend when calling #check_comment" do
      Viking::Defensio.should_receive(:new).and_return(@defensio)
      engine.check_comment(@url, @comment)
    end
    
    it "#check_comment returns a spam_info hash from the backend" do
      @defensio.stub!(:check_comment).and_return :spam => false
      engine.check_comment(@url, @comment).should == {:spam => false}
    end
    
    it "#check_comment returns an empty hash when the backend returned false" do
      @defensio.stub!(:check_comment).and_return false
      engine.check_comment(@url, @comment).should == {}
    end
  end
  
  describe 'when the defensio key is missing' do
    before :each do
      @site = Site.new :spam_options => {:engine => 'Defensio', 'Defensio' => {:defensio_url => 'http://domain.com'}}
    end
    
    it 'is not valid' do
      engine.valid?.should be_false
    end
    
    it 'raises NotConfigured when calling #check_comment' do
      lambda { engine.check_comment(@url, @comment) }.should raise_error(SpamEngine::NotConfigured)
    end
  end
  
  describe 'when the defensio url is missing' do
    before :each do
      @site = Site.new :spam_options => {:engine => 'Defensio', 'Defensio' => {:defensio_key => 'key'}}
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
end

# describe 'Spam engines' do
#   fixtures :sites, :sections, :contents, :comments, :anonymouses
#   
#   before :each do
#     @comment = comments(:a_comment)
#     @comment.author = anonymouses(:an_anonymous) # wtf
#     @comment.commentable = contents(:an_article)
#     
#     http = Net::HTTP.new("url")
#     Net::HTTP.stub!(:new).and_return(http)
#     
#     @options  = { :permalink => "http://www.example.org/an-article", 
#                   :user_ip => '1.1.1.1', 
#                   :user_agent => 'the-agent', 
#                   :referrer => 'the-referer', 
#                   :comment_author => "anonymous", 
#                   :comment_author_email => "anonymous@email.org", 
#                   :comment_author_url => "http://www.example.org", 
#                   :comment_content => "comment body" }
#   end
#   
#   describe '#check_comment' do
#     it "calls #check_comment on the Defensio Viking engine when the site's spam_option :engine is 'Defensio'" do
#       sites(:site_1).update_attributes :spam_options => {:engine => 'Defensio', 'Defensio' => {:defensio_key => 'key', :defensio_url => 'http://domain.com'}}
#       @comment.section.site.spam_engine.send(:defensio).should_receive(:check_comment).with(@options).and_return :spam => false, :spaminess => 0.0, :signature => 'signature'
#       @comment.check_spam('http://www.example.org/an-article', @comment)
#       @comment.spam_info.should == {:spam => false, :spaminess => 0.0, :signature => 'signature'}
#     end
#   end
# end