require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Object do
  
  describe '#to_param' do
    it 'should return a representation of an object' do
      1.to_param.should == '1'
    end
  end
  
  describe '#to_query' do
    it 'should CGI escape an object and its associated key' do
      'foo'.to_query('bar').should == 'bar=foo'
    end
  end
  
end