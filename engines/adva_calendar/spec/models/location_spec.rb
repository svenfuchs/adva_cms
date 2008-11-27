require File.dirname(__FILE__) + '/../spec_helper'

describe Location do
  include Matchers::ClassExtensions
  before :each do
    @location = Location.new(:title => 'Museumsquartier')
  end
  describe "relations" do
    it "should have many events" do
      @location.should have_many(:events)
    end
  end
end