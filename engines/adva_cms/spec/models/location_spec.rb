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
  
  describe "method" do
    it "should have oneliner" do
      @location.oneliner.should ==('Museumsquartier, Museumsplatz 1, 1160 Vienna')

      location2 = Location.new(:title => 'Museumsquartier', :town => 'Vienna', :postcode => '')
      location2.oneliner.should ==('Museumsquartier, Vienna')

    end
  end

end
