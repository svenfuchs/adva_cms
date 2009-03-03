# require File.dirname(__FILE__) + '/../spec_helper'
# 
# describe "Routing Filter::Categories" do
#   include SpecRoutingHelper
#   #include SpecMocks
# 
#   describe "#before_recognize_path" do
#     before :each do
#       @category = mock_category
#       @categories_proxy = mock 'categories_proxy', :find_by_path => @category
#       @section = mock_section(:types => ['Page'], :categories => @categories_proxy)
#       Section.stub!(:find).and_return @section
#       Site.stub!(:find_by_host).and_return mock('site', :sections => mock('sections_proxy', :root => @section))
# 
#     end
# 
#     ['', '/de'].each do |locale|
#       describe "given an incoming section and category path with#{locale.blank? ? 'out' : ''} a locale (like #{locale}/sections/:section_id/categories/:category_path)" do
#         controller_name 'base'
# 
#         it "should replace the :category_path with the :category_id" do
#           before_recognize_path(:categories, "#{locale}/sections/1/categories/category").should == "#{locale}/sections/1/categories/1"
#         end
# 
#         it "should replace the :category_path with the :category_id when the path is terminated by a slash" do
#           before_recognize_path(:categories, "#{locale}/sections/1/categories/category/").should == "#{locale}/sections/1/categories/1/"
#         end
# 
#         it "should replace the :category_path with the :category_id when the path has trailing stuff" do
#           before_recognize_path(:categories, "#{locale}/sections/1/categories/category/whatever").should == "#{locale}/sections/1/categories/1/whatever"
#         end
#       end
# 
#       describe "given an incoming category path without a section segment and with#{locale.blank? ? "out" : ""} a locale (like #{locale}/categories/:category_path)" do
#         controller_name "base"
# 
#         it "should replace the :category_path with the :category_id and prepend the section segments" do
#           before_recognize_path(:categories, "#{locale}/categories/category").should == "#{locale}/sections/1/categories/1"
#         end
# 
#         it "should replace the :category_path with the :category_id and prepend the section segments when the path is terminated by a slash" do
#           before_recognize_path(:categories, "#{locale}/categories/category/").should == "#{locale}/sections/1/categories/1/"
#         end
# 
#         it "should replace the :category_path with the :category_id and prepend the section segments when the path has trailing stuff" do
#           before_recognize_path(:categories, "#{locale}/categories/category/whatever").should == "#{locale}/sections/1/categories/1/whatever"
#         end
#       end
#     end
#   end
# 
#   describe "#after_url_helper" do
#     controller_name 'base'
# 
#     before :each do
#       Category.stub!(:find).and_return mock_category
#     end
# 
#     it "should replace a categories/:category_id segment with categories/:category_path" do
#       after_url_helper(:categories, nil, '/categories/1').should == '/categories/category'
#     end
#   end
# end
