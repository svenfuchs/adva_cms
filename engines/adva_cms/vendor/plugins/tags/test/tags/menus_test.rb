require File.dirname(__FILE__) + "/../test_helper"

class TopMenu < Menu::Group
  define do |g|
    g.menu :left do |m|
      m.item :sections, :url => 'path/to/sections'
    end
    g.menu :right do |m|
      m.item :settings, :url => 'path/to/settings'
    end
  end
end

class BlogMenu < Menu::Group
  define do |g|
    g.name :main
    g.parent TopMenu.build[:left][:sections]

    g.menu :left do |m|
      m.item :articles, :url => '/path/to/articles'
      m.item :categories, :url => '/path/to/categories'
    end

    g.menu :right do |m|
      m.activates lambda { |m| m.parent[:left][:articles] }
      m.item :new, :url => '/path/to/articles/new'
      m.item :edit, :url => '/path/to/articles/edit'
    end
  end
end

# class WikiMenu < Menu::Menu
#   menu :left, :class => 'main left' do |m|
#     m.parent TopMenu.instance #[:left][:sections]
#     m.item :wikipages, :url => lambda { '/path/to/wikipages' }
#   end
# end

module TagsTests
  class MenuDefinitionTest < ActiveSupport::TestCase
    test "defers the name from the class name" do
      assert_equal :top, TopMenu.new.name
    end
    
    test "hash style access" do
      assert_not_nil BlogMenu.build[:left]
    end

    test "hash style access w/ multiple keys" do
      assert_not_nil BlogMenu.build[:left, :sections, :main]
    end

    test "build applies definitions" do
      top = BlogMenu.build
      sections = top[:left][:sections]
      main = sections[:main]
      articles = main[:left][:articles]

      assert_equal :top, top.name
      assert_equal :left, top[:left].name
      assert_equal :sections, sections.name
      assert_equal :main, main.name
      assert_equal :left, main[:left].name
      assert_equal :right, main[:right].name
      assert_equal :articles, articles.name
      assert_equal :new, main[:right][:new].name

      assert_equal top[:left].object_id, top[:left].parent.children.first.object_id
      assert_equal main.object_id, main.parent.children.first.object_id
      assert_equal main[:left].object_id, main[:left].parent.children.first.object_id
      assert_equal main[:right].object_id, main[:right].parent.children[1].object_id

      assert top.is_a?(Menu::Group)
      assert main.is_a?(Menu::Group)

      assert_equal Menu::Menu, top[:left].class
      assert_equal Menu::Menu, main[:left].class
      assert_equal Menu::Menu, main[:right].class

      assert_equal Menu::Item, top[:left].children.first.class
      assert_equal Menu::Item, main[:left].children.first.class
      assert_equal Menu::Item, main[:right].children.first.class
    end

    test "returns topmost node as root" do
      assert_equal :top, BlogMenu.build[:left][:sections][:main][:right][:new].root.name
    end

    test "activates the expected nodes" do
      top = BlogMenu.build
      top.activate('/path/to/articles/edit')

      assert top.active
      assert top[:left].active
      assert top[:left][:sections].active
      assert top[:left][:sections][:main].active
      assert top[:left][:sections][:main][:left].active
      assert top[:left][:sections][:main][:left][:articles].active
      assert top[:left][:sections][:main][:right].active
      assert top[:left][:sections][:main][:right][:edit].active

      assert top[:right].active == false
      assert top[:right][:settings].active == false
      assert top[:left][:sections][:main][:left][:categories].active == false
      assert top[:left][:sections][:main][:right][:new].active == false
    end
  end
  
  class MenuItemTest < ActiveSupport::TestCase
    test "renders a span tag if no url is set" do
      Menu::Item.new
    end

    test "renders an a tag if no url is set" do
    end
  end
end