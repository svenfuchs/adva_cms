class Test::Unit::TestCase
  share :a_wiki do
    before do 
      @site ||= Site.make
      # FIXME make machinist work with STI instantiation somehow?
      @section = Wiki.find Wiki.make(:site => @site, :type => 'Wiki').id 
    end
  end
end