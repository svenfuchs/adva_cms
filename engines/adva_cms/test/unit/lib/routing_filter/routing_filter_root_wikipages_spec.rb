# we're using a standard route instead of this filter now

# require File.dirname(__FILE__) + '/../spec_helper'
# require File.dirname(__FILE__) + '/../spec_routing_helper'
# require File.dirname(__FILE__) + '/../spec_mocks'
#
# describe "Routing Filter::RootWikipages" do
#   include SpecRoutingHelper
#   include SpecMocks
#
#   describe "#before_recognize_path" do
#     describe "given an incoming root wikipage path with no locale (like /pages/something)" do
#       controller_name 'base'
#
#       it "should insert the section path segment to the path when the root section is a wiki" do
#         Site.should_receive(:find_by_host).and_return mock_site(mock_wiki)
#         before_recognize_path(:root_wikipages, '/pages/something').should == '/wiki/pages/something'
#       end
#
#       it "should not modify the path when the root section is not a wiki" do
#         Site.should_receive(:find_by_host).and_return mock_site(mock_section)
#         before_recognize_path(:root_wikipages, '/pages/something').should == '/pages/something'
#       end
#     end
#
#     describe "given an incoming root wikipage path with a locale (like /de/pages/something)" do
#       controller_name 'base'
#
#       it "should insert the section path segment to the path when the root section is a wiki" do
#         Site.should_receive(:find_by_host).and_return mock_site(mock_wiki)
#         before_recognize_path(:root_wikipages, '/de/pages/something').should == '/de/wiki/pages/something'
#       end
#
#       it "should not modify the path when the root section is not a wiki" do
#         Site.should_receive(:find_by_host).and_return mock_site(mock_section)
#         before_recognize_path(:root_wikipages, '/de/pages/something').should == '/de/pages/something'
#       end
#     end
#   end
# end
