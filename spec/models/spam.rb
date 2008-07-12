require File.dirname(__FILE__) + '/../spec_helper'

describe 'Spam engines' do
  fixtures :sites, :sections, :contents
  
  before :each do
    @site = sites(:site_1)
    @section = sections(:home)
    
    @article = contents(:an_article)
    @anonymous = Anonymous.new :name     => 'anonymous', 
                               :email    => 'anonymous@email.org', 
                               :homepage => 'http://www.example.org',
                               :agent    => 'the-agent',
                               :ip       => '1.1.1.1',
                               :referer  => 'the-referer'
                               
    @comment   = Comment.new   :body             => 'comment body', 
                               :site_id          => @site.id,
                               :section_id       => @section.id,
                               :section          => @section,
                               :author           => @anonymous,
                               :commentable_type => 'Article',
                               :commentable_id   => @article.id
  end
  
  it "#check_comment on a Section ends up calling #check_comment on the Akismet Viking engine" do
    @site.update_attributes :spam_options => {:engine => 'Akismet', 'Akismet' => {:akismet_key => 'key', :akismet_url => 'http://domain.com'}}
    options = { :permalink => "http://www.example.org/an-article", 
                :user_ip => '1.1.1.1', 
                :user_agent => 'the-agent', 
                :referrer => 'the-referer', 
                :comment_author => "anonymous", 
                :comment_author_email => "anonymous@email.org", 
                :comment_author_url => "http://www.example.org", 
                :comment_content => "comment body" }
                
    @comment.section.site.spam_engine.send(:akismet).should_receive(:check_comment).with(options).and_return true
    @comment.check_spam('http://www.example.org/an-article', @comment)
    @comment.spam_info.should == {:spam => false}
  end
  
  it "#check_comment on a Section ends up calling #check_comment on the Defensio Viking engine" do
    @site.update_attributes :spam_options => {:engine => 'Defensio', 'Defensio' => {:defensio_key => 'key', :defensio_url => 'http://domain.com'}}
    options = { :permalink => "http://www.example.org/an-article", 
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
                 
    @comment.section.site.spam_engine.send(:defensio).should_receive(:check_comment).with(options).and_return :spam => false, :spaminess => 0.0, :signature => 'signature'
    @comment.check_spam('http://www.example.org/an-article', @comment)
    @comment.spam_info.should == {:spam => false, :spaminess => 0.0, :signature => 'signature'}
  end
end