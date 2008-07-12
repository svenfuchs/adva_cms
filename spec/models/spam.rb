require File.dirname(__FILE__) + '/../spec_helper'

describe 'Spam engines' do
  fixtures :sites, :sections, :contents, :comments, :anonymouses
  
  before :each do
    @comment = comments(:a_comment)
    @comment.author = anonymouses(:an_anonymous) # wtf
    @comment.commentable = contents(:an_article)
    
    http = Net::HTTP.new("url")
    Net::HTTP.stub!(:new).and_return(http)
    
    @akismet_options  = { :permalink => "http://www.example.org/an-article", 
                          :user_ip => '1.1.1.1', 
                          :user_agent => 'the-agent', 
                          :referrer => 'the-referer', 
                          :comment_author => "anonymous", 
                          :comment_author_email => "anonymous@email.org", 
                          :comment_author_url => "http://www.example.org", 
                          :comment_content => "comment body" }

    @defensio_options = { :permalink => "http://www.example.org/an-article", 
                          :user_ip => '1.1.1.1', 
                          :referrer => 'the-referer', 
                          :comment_author => "anonymous", 
                          :comment_author_email => "anonymous@email.org", 
                          :comment_author_url => "http://www.example.org", 
                          :comment_content => "comment body", 
                          :article_date => @comment.commentable.published_at, 
                          :comment_type => "comment", 
                          :user_logged_in => nil,
                          :trusted_user => nil }
  end
  
  describe '#check_comment' do
    it "approves the comment when the site's spam_option :engine is 'None' and approve_comments is true" do
      sites(:site_1).update_attributes :spam_options => {:engine => 'None', :approve_comments => true}
      @comment.check_spam('http://www.example.org/an-article', @comment)
      @comment.approved?.should be_true
    end
    
    it "does not approve the comment when the site's spam_option :engine is 'None' and approve_comments is not true" do
      sites(:site_1).update_attributes :spam_options => {:engine => 'None', :approve_comments => false}
      @comment.check_spam('http://www.example.org/an-article', @comment)
      @comment.approved?.should be_false
    end
    
    it "calls #check_comment on the None SpamEngine when the site's spam_option :engine is 'None'" do
      sites(:site_1).update_attributes :spam_options => {:engine => 'None', :approve_comments => false}
      @comment.section.site.spam_engine.should be_instance_of(SpamEngine::None)
      @comment.check_spam('http://www.example.org/an-article', @comment)
      @comment.spam_info.should == {}
    end
    
    it "calls #check_comment on the Akismet Viking engine when the site's spam_option :engine is 'Akismet'" do
      sites(:site_1).update_attributes :spam_options => {:engine => 'Akismet', 'Akismet' => {:akismet_key => 'key', :akismet_url => 'http://domain.com'}}
      @comment.section.site.spam_engine.send(:akismet).should_receive(:check_comment).with(@akismet_options).and_return true
      @comment.check_spam('http://www.example.org/an-article', @comment)
      @comment.spam_info.should == {:spam => false}
    end
  
    it "calls #check_comment on the Defensio Viking engine when the site's spam_option :engine is 'Defensio'" do
      sites(:site_1).update_attributes :spam_options => {:engine => 'Defensio', 'Defensio' => {:defensio_key => 'key', :defensio_url => 'http://domain.com'}}
      @comment.section.site.spam_engine.send(:defensio).should_receive(:check_comment).with(@defensio_options).and_return :spam => false, :spaminess => 0.0, :signature => 'signature'
      @comment.check_spam('http://www.example.org/an-article', @comment)
      @comment.spam_info.should == {:spam => false, :spaminess => 0.0, :signature => 'signature'}
    end
  end
end