require File.expand_path(File.dirname(__FILE__) + '/../../../engines/adva_cms/test/test_helper')

class CellTestController
  def site
    @site ||= Site.first
  end

  def section
    site.sections.first
  end
end