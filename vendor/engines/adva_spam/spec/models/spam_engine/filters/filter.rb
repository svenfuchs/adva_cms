require File.dirname(__FILE__) + '/../../spec_helper'

describe 'SpamEngine:', 'the Filter module' do
  it "returns the registered filter names" do
    SpamEngine::Filter.names.should == ['Default', 'Akismet', 'Defensio']
  end
end