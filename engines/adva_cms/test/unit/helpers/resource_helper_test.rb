require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class ResourceHelperTest < ActionView::TestCase
  include ResourceHelper
  include ContentHelper
  attr_reader :controller

  def setup
    super
    @old_routing_filter_active, RoutingFilter.active = RoutingFilter.active, false

    @blog_article = Article.find_by_title 'a blog article'
    @page_article = Article.find_by_title 'a page article'
    @blog = @blog_article.section
    @page = @page_article.section
    @site = @blog.site

    @controller = Class.new { def controller_path; 'articles' end }.new
    I18n.backend.send :merge_translations, :en, :foo => 'FOO'

    @paths = {
      :blog_articles => {
        :show  => %r(^/blogs/\d+/\d{4}/\d{1,2}/\d{1,2}/a-blog-article$),
      },
      :page_articles => {
        :show  => %r(^/pages/\d+/articles/a-page-article$),
      }
    }
  end

  def teardown
    RoutingFilter.active = @old_routing_filter_active
  end

  test 'resource_path helpers for articles' do
    show_path(@blog_article).should =~ @paths[:blog_articles][:show]
    show_path(@page_article).should =~ @paths[:page_articles][:show]
  end

  test 'resource_link helpers for articles' do
    assert_html link_to_show(@blog_article), 'a[href=?][class=show article]', @paths[:blog_articles][:show], 'Show'
    assert_html link_to_show(@page_article), 'a[href=?][class=show article]', @paths[:page_articles][:show], 'Show'
  end
end

class AdminResourceHelperTest < ActionView::TestCase
  include ResourceHelper
  attr_reader :controller

  def setup
    super
    @article = Article.find_by_title 'a page article'
    @section = @article.section
    @category = @article.categories.first

    @site = @section.site
    @controller = Class.new { def controller_path; 'admin/articles' end }.new
    I18n.backend.send :merge_translations, :en, :foo => 'FOO'

    @paths = {
      :articles => {
        :index => %r(^/admin/sites/\d+/sections/\d+/articles$),
        :new   => %r(^/admin/sites/\d+/sections/\d+/articles/new$),
        :show  => %r(^/admin/sites/\d+/sections/\d+/articles/\d+$),
        :edit  => %r(^/admin/sites/\d+/sections/\d+/articles/\d+/edit$),
      },
      :categories => {
        :index => %r(^/admin/sites/\d+/sections/\d+/categories$),
        :new   => %r(^/admin/sites/\d+/sections/\d+/categories/new$),
        :show  => %r(^/admin/sites/\d+/sections/\d+/categories/\d+$),
        :edit  => %r(^/admin/sites/\d+/sections/\d+/categories/\d+/edit$),
      },
      :sections => {
        :index => %r(^/admin/sites/\d+/sections$),
        :new   => %r(^/admin/sites/\d+/sections/new$),
        :show  => %r(^/admin/sites/\d+/sections/\d+$),
        :edit  => %r(^/admin/sites/\d+/sections/\d+/edit$),
      },
      :themes => {
        :index => %r(^/admin/sites/\d+/themes$),
        :new   => %r(^/admin/sites/\d+/themes/new$),
        :show  => %r(^/admin/sites/\d+/themes/\d+$),
        :edit  => %r(^/admin/sites/\d+/themes/\d+/edit$),
      },
      :sites => {
        :index => %r(^/admin/sites$),
        :new   => %r(^/admin/sites/new$),
        :show  => %r(^/admin/sites/\d+$),
        :edit  => %r(^/admin/sites/\d+/edit$),
      }
    }
  end

  def protect_against_forgery?
    false
  end

  test 'resource_path helpers for articles' do
    index_path([@section, :article]).should =~ @paths[:articles][:index]
    new_path([@section, :article]).should =~ @paths[:articles][:new]
    show_path(@article).should =~ @paths[:articles][:show]
    edit_path(@article).should =~ @paths[:articles][:edit]
  end

  test 'resource_path helpers for categories' do
    index_path([@section, :category]).should =~ @paths[:categories][:index]
    new_path([@section, :category]).should =~ @paths[:categories][:new]
    show_path(@category).should =~ @paths[:categories][:show]
    edit_path(@category).should =~ @paths[:categories][:edit]
  end

  test 'resource_path helpers for sections' do
    index_path([@site, :section]).should =~ @paths[:sections][:index]
    new_path([@site, :section]).should =~ @paths[:sections][:new]
    show_path(@section).should =~ @paths[:sections][:show]
    edit_path(@section).should =~ @paths[:sections][:edit]
  end

  test 'resource_path helpers for sites' do
    index_path([:site]).should =~ @paths[:sites][:index]
    new_path([:site]).should =~ @paths[:sites][:new]
    show_path(@site).should =~ @paths[:sites][:show]
    edit_path(@site).should =~ @paths[:sites][:edit]
  end

  test 'resource_link helpers for articles' do
    assert_html link_to_index([@section, :article]), 'a[href=?][class=index articles]', @paths[:articles][:index], 'Articles'
    assert_html link_to_new([@section, :article]), 'a[href=?][class=new article]', @paths[:articles][:new], 'New'
    assert_html link_to_show(@article), 'a[href=?][class=show article]', @paths[:articles][:show], 'Show'
    assert_html link_to_edit(@article), 'a[href=?][class=edit article]', @paths[:articles][:edit], 'Edit'
    assert_html link_to_delete(@article), 'a[href=?][class=delete article]', @paths[:articles][:show], 'Delete'
  end

  test 'resource_link helpers for articles with text' do
    assert_html link_to_index(:foo, [@section, :article]), 'a[href=?][class=index articles]', @paths[:articles][:index], 'FOO'
    assert_html link_to_new(:foo, [@section, :article]), 'a[href=?][class=new article]', @paths[:articles][:new], 'FOO'
    assert_html link_to_show(:foo, @article), 'a[href=?][class=show article]', @paths[:articles][:show], 'FOO'
    assert_html link_to_edit(:foo, @article), 'a[href=?][class=edit article]', @paths[:articles][:edit], 'FOO'
    assert_html link_to_delete(:foo, @section), 'a[href=?][class=delete section]', @paths[:sections][:show], 'FOO'
  end

  test 'resource_link helpers for sections' do
    assert_html link_to_index([@site, :section]), 'a[href=?][class=index sections]', @paths[:sections][:index], 'Sections'
    assert_html link_to_new([@site, :section]), 'a[href=?][class=new section]', @paths[:sections][:new], 'Create a new section'
    assert_html link_to_show(@section), 'a[href=?][class=show section]', @paths[:sections][:show], 'Show'
    assert_html link_to_edit(@section), 'a[href=?][class=edit section]', @paths[:sections][:edit], 'Settings'
    assert_html link_to_delete(@section), 'a[href=?][class=delete section]', @paths[:sections][:show], 'Delete'
  end

  test 'resource_link helpers for sites' do
    assert_html link_to_index([:site]), 'a[href=?][class=index sites]', @paths[:sites][:index], 'Sites'
    assert_html link_to_new([:site]), 'a[href=?][class=new site]', @paths[:sites][:new], 'New'
    assert_html link_to_show(@site), 'a[href=?][class=show site]', @paths[:sites][:show], 'Show'
    assert_html link_to_edit(@site), 'a[href=?][class=edit site]', @paths[:sites][:edit], 'Settings'
    assert_html link_to_delete(@site), 'a[href=?][class=delete site]', @paths[:sites][:show], 'Delete'
  end

  test 'should populate title option with default value taken from adva.titles.#{action}' do
    link_to_new(@article).should =~ /title="New"/
    link_to_show(@article).should =~ /title="Show"/
    link_to_edit(@article).should =~ /title="Edit"/
    link_to_delete(@article).should =~ /title="Delete"/
  end

  test 'should not populate title option because there is no translation for given action' do
    link_to_index(@article).should_not =~ /title=/
  end

  test 'should return given title' do
    link_to_index(@article,   :title => "test-title").should =~ /title="test-title"/
    link_to_new(@article,     :title => "test-title").should =~ /title="test-title"/
    link_to_show(@article,    :title => "test-title").should =~ /title="test-title"/
    link_to_edit(@article,    :title => "test-title").should =~ /title="test-title"/
    link_to_delete(@article,  :title => "test-title").should =~ /title="test-title"/
  end

  test 'resurce_url should return resource path with subclass' do
    #TODO currently there are no subclass modelis in adva_cms to test against
  end
end
