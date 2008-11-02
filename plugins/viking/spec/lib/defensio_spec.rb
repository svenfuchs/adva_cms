require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "Defensio" do

  attr_accessor :defensio, :http

  before(:each) do
    self.defensio = Viking.connect('defensio', valid_options)
    self.http     = Net::HTTP.new('url')
    Net::HTTP.stub!(:new).and_return(http)
  end
  
  after(:each) do
    self.defensio = nil
    self.http     = nil
  end
  
  def valid_options
    {
      :blog    => 'foo', 
      :api_key => 'bar'
    }
  end
  
  def defensio_with_bad_options
    Viking.connect('defensio', {})
  end
  
  describe '.new' do
    it 'should not have verified options when initialized' do
      defensio_with_bad_options.send(:verify_options).should == false
    end
  end
  
  describe '#verified?' do
    it "should be verified when all parameters are provided" do
      http.should_receive(:post).and_return(stub("response", :body => "defensio-result:\n  status: success"))
      
      defensio.should be_verified # called twice to make sure #validate-key is not called twice
      defensio.should be_verified
    end
    
    it "should not be verified if Defensio doesn't validate" do
      http.should_receive(:post).and_return(stub("response", :body => "defensio-result:\n  status: fail"))
      defensio.should_not be_verified
    end
    
    it "should not be verified if its options are invalid" do
      defensio_with_bad_options.should_not be_verified
    end
  end
  
  describe '#check_article' do
    it 'should be false if its options are invalid' do
      defensio_with_bad_options.check_article({}).should be_false
    end
    
    it 'should check the article with Defensio' do
      http.should_receive(:post).and_return(stub("response", :body => "defensio-result:\n  foo: bar"))
      defensio.check_article({})[:foo].should == "bar"
    end
  end
  
  describe '#check_comment' do
    it 'should be false if its options are invalid' do
      defensio_with_bad_options.check_comment({}).should be_false
    end
    
    it 'should raise a NoMethodError if options are provided without an article_date that responds to strftime' do
      http.should_not_receive(:post)
      lambda { defensio.check_comment(:article_date => nil) }.should raise_error(NoMethodError)
    end
    
    it 'should check the comment with Defensio' do
      http.should_receive(:post).and_return(stub("response", :body => "defensio-result:\n  foo: bar"))
      defensio.check_comment(:article_date => Time.now)[:foo].should == "bar"
    end
  end
  
  describe '#mark_as_spam' do
    it 'should be false if its options are invalid' do
      defensio_with_bad_options.mark_as_spam({}).should be_false
    end
    
    it 'should mark the comments whose signatures are provided as spam' do
      http.should_receive(:post).and_return(stub("response", :body => "defensio-result:\n  foo: bar"))
      defensio.mark_as_spam(:signatures => "1,2,3")[:foo].should == "bar"
    end
  end
  
  describe '#mark_as_ham' do
    it 'should be false if its options are invalid' do
      defensio_with_bad_options.mark_as_ham({}).should be_false
    end
    
    it 'should mark the comments whose signatures are provided as spam' do
      http.should_receive(:post).and_return(stub("response", :body => "defensio-result:\n  foo: bar"))
      defensio.mark_as_ham(:signatures => "1,2,3").should == { :foo => "bar" }
    end
  end
  
  describe '#stats' do
    it 'should be false if its options are invalid' do
      defensio_with_bad_options.stats.should be_false
    end
    
    it 'should return stats about the blog' do
      http.should_receive(:post).and_return(stub("response", :body => "defensio-result:\n foo: bar"))
      defensio.stats.should == { :foo => "bar" }
    end
  end
  
  describe '#url' do
    it 'should return an URL for the specified action' do
      defensio.url('get-stats').should == '/blog/1.2/get-stats/bar.yaml'
    end
  end
  
  describe '#process_response_body' do
    it 'should return the defensio-response portion of the YAML response as a Hash' do
      Viking::Defensio.publicize_methods do
        v = Viking.connect('defensio', {})
        v.process_response_body("defensio-result:\n  foo: bar").should == { :foo => "bar" }
      end
    end
    
    it 'should return the entire response with failure as the status if the response is not as expected' do
      Viking::Defensio.publicize_methods do
        v = Viking.connect('defensio', {})
        v.process_response_body("foo:\n  bar: baz").should == { :data => { 'foo' => { 'bar' => 'baz' } }, :status => "fail" }
      end
    end
  end

end
