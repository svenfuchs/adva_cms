#require File.dirname(__FILE__) + '/spec_helper'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'lambda_table' ))

describe LambdaTable do
  it "returns nil on non-existent key" do
    LambdaTable.clear
    LambdaTable.lookup( :foo ).should be_nil
  end

  it "returns the registered lambda" do
    LambdaTable.clear
    LambdaTable.register( :foo, lambda { 'Hello World' } )    
    result = LambdaTable.lookup( :foo )
    result.should_not be_nil
    result.call.should == 'Hello World' 
  end

end
