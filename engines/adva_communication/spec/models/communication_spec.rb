require File.dirname(__FILE__) + '/../spec_helper'

describe Communication do
  it "exists" do
    lambda{ Communication.new }.should_not raise_error
  end
end