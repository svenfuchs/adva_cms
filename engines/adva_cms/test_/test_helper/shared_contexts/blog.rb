class Test::Unit::TestCase
  share :a_blog do
    before do 
      @site ||= Site.make
      # FIXME make machinist work with STI instantiation somehow?
      @section = Blog.find Blog.make(:site => @site, :type => 'Blog').id 
    end
  end
end