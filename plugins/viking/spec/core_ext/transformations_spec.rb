require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Hash do
  
  describe '#symbolize_keys' do
    it 'should convert all keys to symbols' do
      { 'foo' => 'bar', :baz => 1 }.symbolize_keys.should == { :foo => 'bar', :baz => 1 }
    end
    
    it 'should handle bad keys' do
      { nil => 'bar' }.symbolize_keys[nil].should == 'bar'
    end
  end
  
  describe '#dasherize_keys' do
    it 'should convert all all underscores in keys to dashes' do
      { 'foo_bar' => 'baz' }.dasherize_keys.should == { 'foo-bar' => 'baz' }
    end
  end
  
  describe '#to_query' do
    it 'should convert to a valid URI query' do
      { :foo => 'baz', :bar => 1 }.to_query.should == 'bar=1&foo=baz'
    end
  end
  
end

describe Array, '#to_query' do
  it 'should convert to a valid URI query' do
    [:foo, :bar].to_query('baz').should == 'baz%5B%5D=foo&baz%5B%5D=bar'
  end
end