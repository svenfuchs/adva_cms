# we're using a standard route instead of this filter now

# require File.dirname(__FILE__) + '/../spec_helper'
# require File.dirname(__FILE__) + '/../spec_routing_helper'
# require File.dirname(__FILE__) + '/../spec_mocks'
#
# describe "Routing Filter::RootBlogArchive" do
#   include SpecRoutingHelper
#   include SpecMocks
#
#   describe "#before_recognize_path" do
#     describe "given an incoming root blog archive path with no locale (like /2008/1)" do
#       controller_name 'base'
#
#       it "should insert the blog path segment to the path when the root section is a blog" do
#         Site.should_receive(:find_by_host).and_return mock_site(mock_blog)
#         before_recognize_path(:root_blog_archive, '/2008/1').should == '/blog/2008/1'
#       end
#
#       it "should not modify the path when the root section is not a blog" do
#         Site.should_receive(:find_by_host).and_return mock_site(mock_section)
#         before_recognize_path(:root_blog_archive, '/2008/1').should == '/2008/1'
#       end
#     end
#
#     describe "given an incoming root blog archive path with a locale and trailing stuff (like /de/2008/1/something)" do
#       controller_name 'base'
#
#       it "should insert the blog path segment to the path when the root section is a blog" do
#         Site.should_receive(:find_by_host).and_return mock_site(mock_blog)
#         before_recognize_path(:root_blog_archive, '/de/2008/1/something').should == '/de/blog/2008/1/something'
#       end
#
#       it "should not modify the path when the root section is not a blog" do
#         Site.should_receive(:find_by_host).and_return mock_site(mock_section)
#         before_recognize_path(:root_blog_archive, '/de/2008/1/something').should == '/de/2008/1/something'
#       end
#     end
#   end
# end
