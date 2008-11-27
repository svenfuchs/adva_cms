require File.dirname(__FILE__) + '/../spec_helper'

describe Location do

  before :each do
    @location = Location.new(:title => 'Museumsquartier', :country => 'Austria', 
        :town => 'Vienna', :address => 'Museumsplatz 1', :postcode => '1160')
  end

  describe "validations" do
    before do
      @location.save
    end

    it "should have a title" do
      @location.title = nil
      @location.should_not be_valid
      @location.errors.on("title").should be
    end
  end

end
