require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class SectionsRoutesTest < ActionController::TestCase
  tests SectionsController
  with_common :a_section, :an_article
  
  describe "routing" do
    ['', '/a-section', '/de', '/de/a-section'].each do |path_prefix|
      ['', '/pages/2'].each do |path_suffix| 
        common = { :section_id => Section.first.id.to_s, :path_prefix => path_prefix, :path_suffix => path_suffix }
        common.merge! :locale => 'de' if path_prefix =~ /de/
        common.merge! :page => 2      if path_suffix =~ /pages/
      
        with_options common do |r|
          r.it_maps :get, '/',                         :action => 'show'
          r.it_maps :get, '/articles/an-article',      :action => 'show', :permalink => 'an-article'
          
          unless path_suffix =~ /pages/
            r.it_maps :get, '/articles/an-article.atom', :action => 'comments', :permalink => 'an-article', :format => 'atom'
          end
        end
      end
    end
    
    # these do not work with a root section path because there's a reguar Comments resource
    with_options :action => 'comments', :format => 'atom', :section_id => Section.first.id.to_s do |r|
      r.it_maps :get, '/a-section/comments.atom'
      r.it_maps :get, '/de/a-section/comments.atom', :locale => 'de'
    end
  end
  
  # FIXME test url_helper rewriting/filtering 
  #
  # describe "the url_helper section_path" do
  #   before :each do
  #     url_rewriter = ActionController::UrlRewriter.new @request, params_from(:get, '/de/section')
  #     @controller.instance_variable_set :@url, url_rewriter
  #     @controller.stub!(:site).and_return @site
  #     @current_section = @section
  #   end
  # 
  #   @section_path = lambda { section_path(@section) }
  #   @article_path = lambda { section_article_path(@section, 'an-article') }
  # 
  #   rewrites_url @section_path, :to => '/',                     :on => [:default_locale, :root_section]
  #   rewrites_url @section_path, :to => '/section',              :on => [:default_locale]
  #   rewrites_url @section_path, :to => '/de',                   :on => [:root_section]
  #   rewrites_url @section_path, :to => '/de/section'
  # 
  #   rewrites_url @article_path, :to => '/articles/an-article',           :on => [:default_locale, :root_section]
  #   rewrites_url @article_path, :to => '/section/articles/an-article',   :on => [:default_locale]
  #   rewrites_url @article_path, :to => '/de/articles/an-article',        :on => [:root_section]
  #   rewrites_url @article_path, :to => '/de/section/articles/an-article'
  # end
end