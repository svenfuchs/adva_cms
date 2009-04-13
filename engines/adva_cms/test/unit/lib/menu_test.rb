# # require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')
#
# require 'rubygems'
# require 'action_controller'
# require 'action_view'
# require 'active_support'
# require 'action_view/test_case'
#
# $:.unshift File.expand_path(File.dirname(__FILE__) + '/../../../lib')
# require 'menu'
#
# class MenuTest < ActionView::TestCase
#   def setup
#     super
#     @old_instances = Menu.instances
#     Menu.instances.clear
#     @view = ActionView::Base.new(File.expand_path(File.dirname(__FILE__) + '/../../fixtures/templates/menu'))
#     @view.request = ActionController::TestRequest.new
#
#     @menu = Menu.instance('foo')
#     @item = Menu::Item.new(:foo)
#     @collection = [Menu::Item.new(:bar), Menu::Item.new(:baz)]
#   end
#
#   def teardown
#     super
#     Menu.instances = @old_instances
#   end
#
#   test "Menu.instance creates a new instance and adds the given definition block" do
#     Menu.instance('foo') { }
#     assert_equal 1, Menu.instances.size
#     assert_equal 1, Menu.instances['foo'].definitions.size
#   end
#
#   test "apply_definitions evaluates registered definition blocks" do
#     menu = Menu.instance('foo') do
#       item 'bar', :foo => :bar
#       menu 'baz'
#     end
#
#     menu.send :apply_definitions, @view
#     assert menu.items.first.is_a?(Menu::Item)
#     assert menu.items.second.is_a?(Menu::Base)
#   end
#
#   test "definition blocks can call methods on the passed view" do
#     menu = Menu.instance('foo') do
#       item 'bar', :url => url_for('that urly')
#     end
#     menu.send :apply_definitions, @view
#
#     assert_equal 'that urly', menu.items.first.options[:url]
#   end
#
#   test "renders expected results" do
#     menu = Menu.instance('foo') do
#       item 'bar', :url => '#'
#       baz = menu 'baz', :caption => 'baz'
#       baz.item 'buz', :url => '#'
#     end
#     expected = '<ul class="menu">' +
#                '<li><a href="#">bar</a></li>' +
#                %(<li>\n\t\t\tbaz\n\t\t\t<ul class="menu"><li><a href="#">buz</a></li></ul></li>) +
#                '</ul>'
#     assert_equal expected, menu.render(@view).gsub(/>\s+</, '><')
#   end
#
#   # insert_at_position
#
#   test "insert_at_position with :before => :first prepends the object to the array" do
#     @menu.send(:insert_at_position, @item, @collection, :_first, nil)
#     assert_equal [:foo, :bar, :baz], @collection.map(&:id)
#   end
#
#   test "insert_at_position with :after => :last appends the object to the array" do
#     @menu.send(:insert_at_position, @item, @collection, nil, :_last)
#     assert_equal [:bar, :baz, :foo], @collection.map(&:id)
#   end
#
#   test "insert_at_position with :before => :baz inserts the object before the item :baz (if found)" do
#     @menu.send(:insert_at_position, @item, @collection, :baz, nil)
#     assert_equal [:bar, :foo, :baz], @collection.map(&:id)
#   end
#
#   test "insert_at_position with :after => :bar inserts the object after the item :bar (if found)" do
#     @menu.send(:insert_at_position, @item, @collection, nil, :bar)
#     assert_equal [:bar, :foo, :baz], @collection.map(&:id)
#   end
#
#   test "insert_at_position with :before => :buh appends the object if :buh can not be found" do
#     @menu.send(:insert_at_position, @item, @collection, :buh, nil)
#     assert_equal [:bar, :baz, :foo], @collection.map(&:id)
#   end
#
#   # populate
#
#   test "populates menu from given populator" do
#     menu = Menu.instance('foo') do
#       menu 'bar', :populate => lambda { [item(:baz), item(:buz)] }
#     end
#     menu.send :apply_definitions, @view
#     assert menu.items.first.is_a?(Menu::Base)
#     assert_equal [Menu::Item], menu.items.first.items.map { |item| item.class }.uniq
#   end
#
#   # highlight
#
#   test "highlights something" do
#     menu = Menu.instance('foo') do
#       baz = menu 'bar', :url => '/bar'
#       baz.item 'baz', :url => '/a/bar/baz'
#     end
#     @view.request.path = '/a/bar/baz'
#     assert_match %r(<li class="active"><a href="/a/bar/baz">baz</a>), menu.render(@view).gsub(/[\t\n]+/, '')
#   end
#
#
# end