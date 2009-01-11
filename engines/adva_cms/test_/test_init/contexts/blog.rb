class Test::Unit::TestCase
  share :a_blog do
    before do
      @section = Blog.find_by_permalink 'a-blog'
      @site = @section.site
      set_request_host!
    end
  end
end