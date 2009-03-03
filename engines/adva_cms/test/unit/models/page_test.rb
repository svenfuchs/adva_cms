require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class PageTest < ActiveSupport::TestCase
  def setup
    super
    @site = Site.first
    # @page = @site.sections.find_by_type(:first, 'Page')
  end

  # CLASS METHODS
  
  test "Section.content_type returns 'Article'" do
    Page.content_type.should == 'Article'
  end
end