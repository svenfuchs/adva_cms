#require File.dirname(__FILE__) + '/spec_helper'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'lambda_table' ))

describe LambdaTable do
  it "returns nil on non-existent key" do
    LambdaTable.lookup( :foo ).should be_nil
  end

  it "returns the registered lambda" do
    LambdaTable.register( :foo, lambda { 'Hello World' } )    
    result = LambdaTable.lookup( :foo )
    result.should_not be_nil
    result.call.should == 'Hello World' 
  end

  it "retains registered lambda in class" do
    result = LambdaTable.lookup( :foo )
    result.should_not be_nil
    result.call.should == 'Hello World' 
  end

  it "overrides the registered lambda" do
    result = LambdaTable.lookup( :foo )
    result.should_not be_nil
    result.call.should == 'Hello World' 
    LambdaTable.register( :foo, lambda { 'Goodbye Cruel World' } )    
    result = LambdaTable.lookup( :foo )
    result.should_not be_nil
    result.call.should == 'Goodbye Cruel World' 
  end

end
