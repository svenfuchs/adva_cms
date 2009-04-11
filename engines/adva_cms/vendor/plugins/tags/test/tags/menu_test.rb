require File.dirname(__FILE__) + "/../test_helper"

module MenuTest
  class TopMenu < Menu::Group
    define :id => 'top', :class => 'top' do |g|
      breadcrumb :site, :content => '<a href="/path/to/site">Site</a>'

      g.menu :left, :class => 'left' do |m|
        m.item :sections, :url => '/path/to/sections'
      end

      g.menu :right, :class => 'right' do |m|
        m.item :settings, :url => '/path/to/settings'
      end
    end
  end

  class BlogMenu < Menu::Group
    define do |g|
      g.id :main
      g.parent TopMenu.new.build.root[:'left.sections']

      g.menu :left do |m|
        m.item :articles, :url => '/path/to/articles'
        m.item :categories, :url => '/path/to/categories'
      end

      g.menu :right do |m|
        m.activates object.parent[:'left.articles']
        m.item :new, :url => '/path/to/articles/new'
        m.item :edit, :url => '/path/to/articles/edit'
      end
    end
  end

  class MenuDefinitionTest < ActiveSupport::TestCase
    def setup
      @top = BlogMenu.new.build.root
    end
    
    test "defers the id from the class name" do
      assert_equal :top, @top.id
    end
  
    test "hash style access" do
      assert_not_nil @top[:left]
    end
  
    test "hash style access w/ multiple keys" do
      assert_not_nil @top[:left, :sections, :main]
    end
  
    test "hash style access w/ dot separated keys" do
      assert_not_nil @top[:'left.sections.main']
    end
  
    test "build applies definitions" do
      sections = @top[:'left.sections']
      main = sections[:main]
      articles = main[:'left.articles']
  
      assert_equal :top, @top.id
      assert_equal :left, @top[:left].id
      assert_equal :sections, sections.id
      assert_equal :main, main.id
      assert_equal :left, main[:left].id
      assert_equal :right, main[:right].id
      assert_equal :articles, articles.id
      assert_equal :new, main[:'right.new'].id
  
      assert_equal @top[:left].object_id, @top[:left].parent.children.first.object_id
      assert_equal main.object_id, main.parent.children.first.object_id
      assert_equal main[:left].object_id, main[:left].parent.children.first.object_id
      assert_equal main[:right].object_id, main[:right].parent.children[1].object_id
  
      assert @top.is_a?(Menu::Group)
      assert main.is_a?(Menu::Group)
  
      assert_equal Menu::Menu, @top[:left].class
      assert_equal Menu::Menu, main[:left].class
      assert_equal Menu::Menu, main[:right].class
  
      assert_equal Menu::Item, @top[:left].children.first.class
      assert_equal Menu::Item, main[:left].children.first.class
      assert_equal Menu::Item, main[:right].children.first.class
    end
    
    test "finds an immediate child" do
      assert_not_nil @top.find(:left)
      assert_not_nil @top[:left].find(:sections)
      assert_not_nil @top[:'left.sections'].find(:main)
      assert_not_nil @top[:'left.sections.main'].find(:left)
    end
    
    test "finds a children's child" do
      assert_not_nil @top.find(:sections)
      assert_not_nil @top[:left].find(:main)
      assert_not_nil @top[:'left.sections'].find(:left)
      assert_not_nil @top[:'left.sections.main'].find(:articles)
    end
    
    test "finds grand-children's children" do
      assert_not_nil @top.find(:new)
    end
  
    test "returns topmost node as root" do
      assert_equal :top, @top[:"left.sections.main.right.new"].root.id
    end
  
    test "activates the expected nodes" do
      @top.activate('/path/to/articles/edit')
  
      assert @top.active
      assert @top[:left].active
      assert @top[:'left.sections'].active
      assert @top[:'left.sections.main'].active
      assert @top[:'left.sections.main.left'].active
      assert @top[:'left.sections.main.left.articles'].active
      assert @top[:'left.sections.main.right'].active
      assert @top[:'left.sections.main.right.edit'].active
  
      assert @top[:right].active == false
      assert @top[:'right.settings'].active == false
      assert @top[:'left.sections.main.left.categories'].active == false
      assert @top[:'left.sections.main.right.new'].active == false
    end
    
    test "can access the active node from root" do
      @top.activate('/path/to/articles/edit')
      assert_equal :edit, @top.active.id
    end
    
    test "breadcrumbs" do
      @top.activate('/path/to/articles/edit')
      assert_equal [:site, :sections, :articles, :edit], @top.active.breadcrumbs.map(&:id)

      breadcrumbs = @top.active.breadcrumbs.map(&:content).join
      assert_html breadcrumbs, 'a[href=/path/to/site]'
      assert_html breadcrumbs, 'a[href=/path/to/sections]'
      assert_html breadcrumbs, 'a[href=/path/to/articles]'
      assert_html breadcrumbs, 'a[href=/path/to/articles/edit]'
    end
  end
  
  class MenuItemTest < ActiveSupport::TestCase
    test "renders a span tag if no url is set" do
      assert_html Menu::Item.new('foo').render, 'li span', 'foo'
    end
  
    test "renders an a tag if no url is set" do
      assert_html Menu::Item.new('foo', :url => 'bar').render, 'li a[href=bar]', 'foo'
    end
  
    test 'uses a text option if given' do
      item = Menu::Item.new('foo', :text => 'foo text')
      assert_html item.render, 'span', 'foo text'
    end
  end

  class MenuTest < ActiveSupport::TestCase
    test "renders a ul tag" do
      menu = Menu::Menu.new
      menu.children << Menu::Item.new('foo')
      assert_html menu.render(:class => 'menu', :id => 'menu'), 'ul[id=menu][class=menu] li span', 'foo'
    end

    test "renders id and class options" do
      menu = TopMenu.new.build
      assert_html menu.render, 'div[id=top][class=top] ul[class=left]'
      assert_html menu.render(:id => 'top-2', :class => 'top-2'), 'div[id=top-2][class=top-2] ul[class=left]'
    end
  end
end