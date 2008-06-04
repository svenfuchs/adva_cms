require 'test/unit'
require 'cgi'
require 'rubygems'
require 'active_support'
require 'mocha'
require 'test/spec'

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

unless Hash.public_instance_methods.any? { |m| m =~ /to_query/ }
  class Object
    def to_param #:nodoc:
      to_s
    end

    def to_query(key) #:nodoc:
      "#{CGI.escape(key.to_s)}=#{CGI.escape(to_param.to_s)}"
    end
  end

  class Array
    def to_query(key) #:nodoc:
      collect { |value| value.to_query("#{key}[]") } * '&'
    end
  end

  class Hash
    def to_query(namespace = nil)
      collect do |key, value|
        value.to_query(key)
      end.sort * '&'
    end
  end
  
  class String
    def dasherize
      gsub(/_/, '-')
    end
  end
end
require 'viking'

context "Viking Connection" do
  specify "should load akismet engine" do
    Viking.connect(:akismet, :api_key => 'foo', :blog => 'bar').class.should == Viking::Akismet
  end
  
  specify "should set default engine" do
    begin
      Viking.default_engine  = :akismet
      Viking.connect_options = { :api_key => 'foo', :blog => 'bar' }
      Viking.default_instance.class.should == Viking::Akismet
      Viking.default_instance.options.should == Viking.connect_options
    ensure
      Viking.default_engine   = nil
      Viking.connect_options  = nil
      Viking.default_instance = nil
    end
  end
end

context "Akismet" do
  setup do
    @viking = Viking.connect :akismet, :api_key => 'foo', :blog => 'bar'
  end
  
  specify "should verify api key" do
    mock_akismet("/1.1/verify-key", {:key => :foo, :blog => :bar}).returns(stub(:body => 'valid'))
    @viking.verified?.should == true # #verified? is called twice to make sure #verify_api_key is not called twice
    @viking.verified?.should == true
  end
  
  specify "should show as unverified with api key" do
    mock_akismet("/1.1/verify-key", {:key => :foo, :blog => :bar}).returns(stub(:body => 'invalid'))
    @viking.verified?.should == false
    @viking.verified?.should == false
  end
  
  specify "should check comment is valid" do
    mock_akismet("/1.1/comment-check").returns(stub(:body => 'false'))
    @viking.check_comment.should == {:message => 'false', :spam => false}
  end
  
  specify "should check comment is spam" do
    mock_akismet("/1.1/comment-check").returns(stub(:body => 'blah'))
    @viking.check_comment.should == {:message => 'blah', :spam => true}
  end

  specify "should mark comment as spam" do
    mock_akismet("/1.1/submit-spam").returns(stub(:body => 'blah'))
    @viking.mark_as_spam.should == {:message => 'blah'}
  end

  specify "should mark comment as ham" do
    mock_akismet("/1.1/submit-ham").returns(stub(:body => 'blah'))
    @viking.mark_as_ham.should == {:message => 'blah'}
  end

  protected
    def mock_akismet(url, options = {})
      Net::HTTP.any_instance.expects(:post).with(url, options.merge(:blog => :bar).to_query, Viking::Akismet.standard_headers)
    end
end

context "Defensio" do
  setup do
    @viking = Viking.connect :defensio, :api_key => 'foo', :blog => 'bar'
  end
  
  specify "should build correct action url" do
    @viking.send(:api_url, 'foo').should == '/blog/1.1/foo/foo.yaml'
  end
  
  specify "should verify api key" do
    mock_defensio("validate-key", {}, {'status' => 'success'})
    @viking.verified?.should == true # #verified? is called twice to make sure #verify_api_key is not called twice
    @viking.verified?.should == true
  end
  
  specify "should show as unverified with api key" do
    mock_defensio("validate-key", {}, {'status' => 'asdf'})
    @viking.verified?.should == false
    @viking.verified?.should == false
  end
  
  specify "should announce article" do
    mock_defensio("announce-article", {}, {'message' => 'whatever'})
    @viking.check_article.should == {:message => 'whatever'}
  end
  
  specify "should check comment is valid" do
    mock_defensio("audit-comment", {}, {'spam' => false, 'spaminess' => 0.1})
    @viking.check_comment.should == {:spaminess => 0.1, :spam => false}
  end
  
  specify "should mark comment as spam" do
    mock_defensio("report-false-negatives", {:user_ip => '123'}, {'message' => 'blah'})
    @viking.mark_as_spam(:user_ip => '123').should == {:message => 'blah'}
  end
  
  specify "should mark comment as ham" do
    mock_defensio("report-false-positives", {}, {'message' => 'blah'})
    @viking.mark_as_ham.should == {:message => 'blah'}
  end
  
  specify "should recover from bad defensio message" do
    data = {'owner-url' => 'bar'}.to_query
    response = {'nothing' => '1'}.to_yaml
    Net::HTTP.any_instance.expects(:post).with(@viking.send(:api_url, 'announce-article'), data, Viking::Defensio.standard_headers).returns(stub(:body => response))
    @viking.check_article.should == {:data => response, :status => 'fail'}
  end
  
  specify "should recover from bad yaml response" do
    data = {'owner-url' => 'bar'}.to_query
    response = 'nothing'
    Net::HTTP.any_instance.expects(:post).with(@viking.send(:api_url, 'announce-article'), data, Viking::Defensio.standard_headers).returns(stub(:body => response))
    @viking.check_article.should == {:data => response, :status => 'fail'}
  end
  
  protected
    def mock_defensio(action, options = {}, response = {})
      data = options.inject({'owner-url' => 'bar'}) do |memo, (key, value)|
        memo[key.to_s.dasherize] = value
        memo
      end.to_query
      response = {'defensio-result' => response.stringify_keys}.to_yaml
      Net::HTTP.any_instance.expects(:post).with(@viking.send(:api_url, action), data, Viking::Defensio.standard_headers).returns(stub(:body => response))
    end
end