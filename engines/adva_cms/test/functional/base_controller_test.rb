# FIXME spec common behaviour on BaseController

# require File.dirname(__FILE__) + '/../spec_helper'
# 
# describe BaseController do
#   include SpecControllerHelper
# 
#   before :each do
#     stub_scenario :empty_site
#   end
# 
#   it "sets the current locale" do
#     BaseController.before_filters.should include(:set_locale)
#   end
# 
#   it "sets the current site" do
#     BaseController.before_filters.should include(:set_site)
#   end
# 
#   it "finds the current site from site_id param" do
#     controller.stub!(:request).and_return mock('request')
#     controller.request.should_receive(:host_with_port)
#     Site.should_receive(:find_by_host).and_return @site
#     @controller.send :set_site
#   end
# end
# 
# describe BaseController, 'event helper' do
#   describe "#trigger_event" do
#     it "triggers an event if the given object is valid" do
#       site = Site.new
#       Event.should_receive(:trigger).with(:site_created, site, controller, {})
#       controller.trigger_event site, :created
#     end
#   end
# end
