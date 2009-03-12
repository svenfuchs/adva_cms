# FIXME implement

# require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')
#
# module GoogleAnalytics
#   class SiteTest < ActiveSupport::TestCase
#     def setup
#       super
#       @site = Site.first
#     end
#
#     test "#has_tracking_enabled? is true if Google Analytics tracking code is set" do
#       @site.google_analytics_tracking_code = "UA-123456"
#       @site.has_tracking_enabled?.should be_true
#     end
#
#     test "#has_tracking_enabled? is false if Google Analytics tracking code is not set" do
#       @site.google_analytics_tracking_code = nil
#       @site.has_tracking_enabled?.should be_false
#     end
#   end
# end