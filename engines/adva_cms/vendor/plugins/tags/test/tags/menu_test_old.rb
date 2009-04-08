require File.dirname(__FILE__) + "/../test_helper"

module TagsTests
  class MenuItemTest < ActiveSupport::TestCase
    test 'menu item builds a span tag when no :url was passed' do
      assert_html Menus::Base.new('foo').render(self), 'span', 'foo'
    end
    
    test 'menu item builds an a tag when a :url was passed' do
      assert_html Menus::Base.new('foo', :url => 'bar').render(self), 'a[href=bar]', 'foo'
    end
    
    test 'can add child items and sets the parent' do
      menu = Menus::Base.new('foo')
      menu.children << Menus::Base.new('bar')
      assert_equal menu, menu.children.first.parent
    end
    
    test 'renders child items' do
      menu = Menus::Base.new('foo')
      menu.children << Menus::Base.new('bar', :url => 'bar')
      assert_html menu.render(self), 'ul li a[href=bar]', 'bar'
    end
    
    test 'uses a text option if given' do
      menu = Menus::Base.new('foo', :text => 'foo text')
      menu.children << Menus::Base.new('bar', :text => 'bar text')
      assert_html menu.render(self), 'ul li span', 'bar text'
    end
    
    test 'renders a nested ul structure' do
      menu = Menus::Base.new('foo')
      menu.children << bar = Menus::Base.new('bar')
      bar.children << baz = Menus::Base.new('baz', :url => 'baz')
      baz.children << Menus::Base.new('buz', :url => 'buz')
      assert_html menu.render(self), 'ul li span', 'bar'
      assert_html menu.render(self), 'ul li ul li a[href=baz]', 'baz'
      assert_html menu.render(self), 'ul li ul li ul li a[href=buz]', 'buz'
    end
    
    test 'knows its level' do
      menu = Menus::Base.new('foo')
      menu.children << bar = Menus::Base.new('bar')
      bar.children << baz = Menus::Base.new('baz', :url => 'baz')
      assert_equal 0, menu.level
      assert_equal 1, bar.level
      assert_equal 2, baz.level
    end
    
    test 'matches with level' do
      foo = Menus::Base.new('foo')
      foo.children << bar = Menus::Base.new('bar')
      assert  foo.matches?(:level => 1)
      assert !foo.matches?(:level => 2)
      assert !bar.matches?(:level => 1)
      assert  bar.matches?(:level => 2)
    end
    
    test 'matches with branch' do
      foo = Menus::Base.new('foo')
      foo.children << bar = Menus::Base.new('bar', :branch => :left)
      foo.children << baz = Menus::Base.new('baz', :branch => :right)
      assert  bar.matches?(:branch => :left)
      assert !bar.matches?(:branch => :right)
      assert !baz.matches?(:branch => :left)
      assert  baz.matches?(:branch => :right)
    end
    
    test 'joins multiple filter conditions by logical and' do
      foo = Menus::Base.new('foo')
      foo.children << bar = Menus::Base.new('bar', :branch => :left)
      foo.children << baz = Menus::Base.new('baz', :branch => :right)
    
      assert  bar.matches?(:level => 2, :branch => :left)
      assert !bar.matches?(:level => 2, :branch => :right)
      assert !bar.matches?(:level => 3, :branch => :left)
      assert !bar.matches?(:level => 3, :branch => :right)
    
      assert !baz.matches?(:level => 2, :branch => :left)
      assert  baz.matches?(:level => 2, :branch => :right)
      assert !baz.matches?(:level => 3, :branch => :left)
      assert !baz.matches?(:level => 3, :branch => :right)
    end
    
    test 'can filter by level' do
      menu = Menus::Base.new('foo')
      menu.children << bar = Menus::Base.new('bar', :url => 'bar')
      bar.children << baz = Menus::Base.new('baz', :url => 'baz')
      baz.children << Menus::Base.new('buz', :url => 'buz')
      assert_html menu.render(self, :level => 1), 'ul li a[href=bar]', 'bar'
      assert_html menu.render(self, :level => 2), 'ul li a[href=baz]', 'baz'
      assert_html menu.render(self, :level => 3), 'ul li a[href=buz]', 'buz'
    end
    
    test 'can filter by branch' do
      menu = Menus::Base.new('foo')
      menu.children << bar = Menus::Base.new('bar', :url => 'bar', :branch => 'left')
      bar.children << Menus::Base.new('bar-2', :url => 'bar-2', :branch => 'left')
      menu.children << baz = Menus::Base.new('baz', :url => 'baz', :branch => 'right')
      baz.children << Menus::Base.new('baz-2', :url => 'baz-2', :branch => 'right')
    
      left = menu.render(self, :branch => 'left')
      right = menu.render(self, :branch => 'right')

      assert_html left, 'ul li a[href=bar]', 'bar'
      assert_html right, 'ul li a[href=baz]', 'baz'
      assert left !~ %r(<ul></ul>)
      assert left !~ %r(class="active")
    end
    
    test 'activates an item with matching url and all of its parents' do
      menu = Menus::Base.new('foo')
      menu.children << bar = Menus::Base.new('bar', :url => 'bar')
      bar.children << baz = Menus::Base.new('baz', :url => 'baz')
      menu.render(self, :activate => 'baz')
      assert_equal [true], [menu.active, bar.active, baz.active].uniq
    end
    
    test 'it only renders active submenus when activate option is given' do
      menu = Menus::Base.new('admin')
      menu.children << sections = Menus::Base.new('sections', :url => 'sites/1/sections', :branch => :left)
      sections.children << Menus::Base.new('sections', :url => 'sites/1/sections', :branch => :left)
      sections.children << Menus::Base.new('new', :url => 'sites/1/sections/new', :branch => :right)
    
      menu.children << settings = Menus::Base.new('settings', :url => 'sites/1/edit', :branch => :right)
      settings.children << Menus::Base.new('settings', :url => 'sites/1/edit', :branch => :left)
      settings.children << Menus::Base.new('cache', :url => 'sites/1/cache', :branch => :right)
    
      main   = menu.render(self, :level => 1, :class => 'main', :activate => 'sites/1/sections')
      second = menu.render(self, :level => 2, :class => 'second')
    
      assert_html main, 'ul[class=main]' do
        assert_select 'li[class=active] a[href=sites/1/sections]'
        assert_select 'li a[href=sites/1/edit]'
      end
    
      assert_html second, 'ul[class=second]' do
        assert_select 'li[class=active] a[href=sites/1/sections]'
        assert_select 'li a[href=sites/1/sections/new]'
      end
    
      main = menu.render(self, :level => 1, :activate => 'sites/1/edit')
      second = menu.render(self, :level => 2)
    
      assert_html main, 'ul' do
        assert_select 'li a[href=sites/1/sections]'
        assert_select 'li[class=active] a[href=sites/1/edit]'
      end
    
      assert_html second, 'ul' do
        assert_select 'li[class=active] a[href=sites/1/edit]'
        assert_select 'li a[href=sites/1/cache]'
      end
    
      main_left    = menu.render(self, :level => 1, :branch => :left, :activate => 'sites/1/sections')
      main_right   = menu.render(self, :level => 1, :branch => :right)
      second_left  = menu.render(self, :level => 2, :branch => :left)
      second_right = menu.render(self, :level => 2, :branch => :right)
    
      assert_html main_left,    'ul li[class=active] a[href=sites/1/sections]', 'sections'
      assert_html main_right,   'ul li a[href=sites/1/edit]', 'settings'
      assert_html second_left,  'ul li[class=active] a[href=sites/1/sections]', 'sections'
      assert_html second_right, 'ul li a[href=sites/1/sections/new]', 'new'
    
      main_left    = menu.render(self, :level => 1, :branch => :left, :activate => 'sites/1/sections/new')
      main_right   = menu.render(self, :level => 1, :branch => :right)
      second_left  = menu.render(self, :level => 2, :branch => :left)
      second_right = menu.render(self, :level => 2, :branch => :right)
    
      assert_html main_left,    'ul li[class=active] a[href=sites/1/sections]', 'sections'
      assert_html main_right,   'ul li a[href=sites/1/edit]', 'settings'
      assert_html second_left,  'ul li a[href=sites/1/sections]', 'sections'
      assert_html second_right, 'ul li[class=active] a[href=sites/1/sections/new]', 'new'
    end

    test "can build from definitions" do
      foo = Menus::Base.new('admin')
      foo.children << sections = Menus::Base.new('sections', :url => 'sites/1/sections', :branch => :left)
      foo = foo.render(self, :activate => 'sites/1/sections')
      
      bar = Menus.instance('admin') do
        item 'sections', :url => 'sites/1/sections', :branch => :left
      end
      bar = bar.render(self, :activate => 'sites/1/sections', :build => true)

      assert_equal foo, bar
    end
  end
end