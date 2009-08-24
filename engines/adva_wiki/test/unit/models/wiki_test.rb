require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class WikiTest < ActiveSupport::TestCase
  def setup
    super
    @wiki = Wiki.new
  end

  test "is a kind of Section" do
    @wiki.should be_kind_of(Section)
  end

  test "has many wikipages" do
    @wiki.should have_many(:wikipages)
  end

  test ".content_type returns 'Wikipage'" do
    Wiki.content_type.should == 'Wikipage'
  end
end