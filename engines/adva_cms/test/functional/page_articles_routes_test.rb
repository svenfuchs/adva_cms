require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class PageArticlesRoutesTest < ActionController::TestCase
  tests ArticlesController
  with_common :default_routing_filters, :a_page, :an_article
  
  paths = %W( /pages/1
              /pages/1/comments.atom 
              /pages/1/articles/an-article
              /pages/1/articles/an-article.atom )
  
  paths.each do |path|
    test "regenerates the original path from the recognized params for #{path}" do
      without_routing_filters do
        params = ActionController::Routing::Routes.recognize_path(path, :method => :get)
        assert_equal path, @controller.url_for(params.merge(:only_path => true))
      end
    end
  end
  
  describe "routing" do
    ['', '/a-page', '/de', '/de/a-page'].each do |path_prefix|
      ['', '/pages/2'].each do |path_suffix|
        common = { :section_id => Section.first.id.to_s, :path_prefix => path_prefix, :path_suffix => path_suffix }
        common.merge! :locale => 'de' if path_prefix =~ /de/
        common.merge! :page => 2      if path_suffix =~ /pages/
  
        with_options common do |r|
          r.it_maps :get, '/',                         :action => 'index'
          r.it_maps :get, '/articles/an-article',      :action => 'show', :permalink => 'an-article'
  
          unless path_suffix =~ /pages/
            r.it_maps :get, '/articles/an-article.atom', :action => 'comments', :permalink => 'an-article', :format => 'atom'
          end
        end
      end
    end
  
    # these do not work with a root page path because there's a reguar Comments resource
    with_options :action => 'comments', :format => 'atom', :section_id => Section.first.id.to_s do |r|
      r.it_maps :get, '/a-page/comments.atom'
      r.it_maps :get, '/de/a-page/comments.atom', :locale => 'de'
    end
  end
  
  describe "the url_helper page_path" do
    before :each do
      # FIXME move to db/populate?
      other = @section.site.sections.create! :title => 'another page'
      other.move_to_left_of @section
  
      url_rewriter = ActionController::UrlRewriter.new @request, :controller => 'pages', :page => @section.id
      @controller.instance_variable_set :@url, url_rewriter
      @controller.instance_variable_set :@site, @site
  
      I18n.default_locale = :en
      I18n.locale = :de
    end
  
    page_path    = lambda { page_path(@section) }
    article_path = lambda { page_article_path(@section, 'an-article') }
  
    it_rewrites page_path, :to => '/',                                :with => [:is_default_locale, :is_root_section]
    it_rewrites page_path, :to => '/a-page',                          :with => [:is_default_locale]
    it_rewrites page_path, :to => '/de',                              :with => [:is_root_section]
    it_rewrites page_path, :to => '/de/a-page'
      
    it_rewrites article_path, :to => '/articles/an-article',          :with => [:is_default_locale, :is_root_section]
    it_rewrites article_path, :to => '/a-page/articles/an-article',   :with => [:is_default_locale]
    it_rewrites article_path, :to => '/de/articles/an-article',       :with => [:is_root_section]
    it_rewrites article_path, :to => '/de/a-page/articles/an-article'
  end
end