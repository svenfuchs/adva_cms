require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class SectionsRoutesTest < ActionController::TestCase
  tests SectionsController
  with_common :a_section, :an_article

  # describe "routing" do
  #   ['', '/a-section', '/de', '/de/a-section'].each do |path_prefix|
  #     ['', '/pages/2'].each do |path_suffix|
  #       common = { :section_id => Section.first.id.to_s, :path_prefix => path_prefix, :path_suffix => path_suffix }
  #       common.merge! :locale => 'de' if path_prefix =~ /de/
  #       common.merge! :page => 2      if path_suffix =~ /pages/
  #
  #       with_options common do |r|
  #         r.it_maps :get, '/',                         :action => 'show'
  #         r.it_maps :get, '/articles/an-article',      :action => 'show', :permalink => 'an-article'
  #
  #         unless path_suffix =~ /pages/
  #           r.it_maps :get, '/articles/an-article.atom', :action => 'comments', :permalink => 'an-article', :format => 'atom'
  #         end
  #       end
  #     end
  #   end
  #
  #   # these do not work with a root section path because there's a reguar Comments resource
  #   with_options :action => 'comments', :format => 'atom', :section_id => Section.first.id.to_s do |r|
  #     r.it_maps :get, '/a-section/comments.atom'
  #     r.it_maps :get, '/de/a-section/comments.atom', :locale => 'de'
  #   end
  # end

  describe "the url_helper section_path" do
    before :each do
      other = @section.site.sections.create! :title => 'another section' # FIXME move to db/populate
      other.move_to_left_of @section

      url_rewriter = ActionController::UrlRewriter.new @request, params_from('/de/a-section')
      @controller.instance_variable_set :@url, url_rewriter
      @controller.instance_variable_set :@site, @site

      I18n.default_locale = :en
      I18n.locale = :de
    end

    section_path = lambda { section_path(@section) }
    article_path = lambda { section_article_path(@section, 'an-article') }

    it_rewrites section_path, :to => '/',                                :with => [:is_default_locale, :is_root_section]
    it_rewrites section_path, :to => '/a-section',                       :with => [:is_default_locale]
    it_rewrites section_path, :to => '/de',                              :with => [:is_root_section]
    it_rewrites section_path, :to => '/de/a-section'

    it_rewrites article_path, :to => '/articles/an-article',             :with => [:is_default_locale, :is_root_section]
    it_rewrites article_path, :to => '/a-section/articles/an-article',   :with => [:is_default_locale]
    it_rewrites article_path, :to => '/de/articles/an-article',          :with => [:is_root_section]
    it_rewrites article_path, :to => '/de/a-section/articles/an-article'
  end
end