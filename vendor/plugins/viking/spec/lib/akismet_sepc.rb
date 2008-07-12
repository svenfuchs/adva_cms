require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "Akismet" do
  
  attr_accessor :akismet, :http

  before(:each) do
    self.akismet = Viking.connect('akismet', valid_options)
    self.http    = Net::HTTP.new("url")
    Net::HTTP.stub!(:new).and_return(http)
  end
  
  after(:each) do
    self.akismet = nil
    self.http    = nil
  end
  
  def valid_options
    {
      :blog    => :foo, 
      :api_key => :bar
    }
  end
  
  describe ".new" do
    it "should not have a verified key when initialized" do
      akismet.send(:verified_key).should be_false
    end
  end
  
  describe '.url' do
    it 'should return an URL for a request' do
      Viking::Akismet.url('bar').should == '/1.1/bar'
    end
  end
  
  describe "#verified?" do
    it "should be verified when all parameters are provided" do
      http.should_receive(:post).and_return(stub("response", :body => "valid"))
      
      akismet.should be_verified # #verified? is called twice to make sure #verify_api_key is not called twice
      akismet.should be_verified
    end
    
    it "should not be verified if Akismet doesn't validate" do
      http.should_receive(:post).and_return(stub("response", :body => "invalid"))
      akismet.should_not be_verified
    end
    
    it "should not be verified if its options are invalid" do
      Viking.connect('akismet', {}).should_not be_verified
    end
  end
  
  describe "#check_comment" do
    it "should be false if the instance has invalid options" do
      Viking.connect('akismet', {}).check_comment({}).should be_false
    end
    
    it "should be spam when the response body isn't a valid response" do
      http.should_receive(:post).and_return(stub("response", :body => "invalid"))
      akismet.check_comment(:user_ip => "127.0.0.1", :user_agent => "Mozilla").should == { :message => "invalid", :spam => true }
    end
    
    it "should not be spam when the response body is a valid response" do
      http.should_receive(:post).and_return(stub("response", :body => "false"))
      akismet.check_comment(:user_ip => "127.0.0.1", :user_agent => "Mozilla").should == { :message => "false", :spam => false }
    end
  end
  
  describe "#mark_as_spam" do
    it 'should be false if the instance has invalid options' do
      Viking.connect('akismet', {}).mark_as_spam({}).should be_false
    end
    
    it 'should return the response body' do
      http.should_receive(:post).and_return(stub('response', :body => "foo"))
      akismet.mark_as_spam({}).should == { :message => "foo" }
    end
  end
  
  describe '#mark_as_ham' do
    it 'should be false if the instance has invalid options' do
      Viking.connect('akismet', {}).mark_as_ham({}).should be_false
    end
    
    it 'should return the response body' do
      http.should_receive(:post).and_return(stub('response', :body => "foo"))
      akismet.mark_as_ham({}).should == { :message => "foo" }
    end
  end

end
