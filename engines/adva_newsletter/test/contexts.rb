class Test::Unit::TestCase
  share :site_with_newsletter do
    before do
      @site  = Site.find_by_name("site with newsletter")
      @newsletter = @site.newsletters.first
      @issue = @newsletter.issues.first
    end
  end
end
