require File.dirname(__FILE__) + '<%= '/..' * class_nesting_depth %>/../spec_helper'

describe <%= class_name %> do
  # Replace this with your real tests.
  it "passed" do
    1.should == 1
  end
end
