require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class LocationTest < ActiveSupport::TestCase
  def setup
    super
    @location = Location.new :title    => 'Museumsquartier', 
                             :address  => 'Museumsplatz 1', 
                             :postcode => '1160',
                             :town     => 'Vienna', 
                             :country  => 'Austria'
  end

  test "is invalid without a title" do
    @location.title = nil
    @location.should_not be_valid
    @location.errors.on("title").should_not be_nil
  end

  test "oneliner returns a concatenation of non-empty attributes" do
    @location.oneliner.should == 'Museumsquartier, Museumsplatz 1, 1160 Vienna'

    @location.address = ''
    @location.postcode = ''
    @location.country = ''
    @location.oneliner.should == 'Museumsquartier, Vienna'
  end
end
