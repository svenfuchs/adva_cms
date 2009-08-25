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

require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class BaseControllerTest < ActionController::TestCase
  tests ArticlesController # yuk!
  with_common :an_unpublished_section, :rescue_action_in_public

  describe 'GET to :index' do
    action { get :index, params_from('/an-unpublished-section') }

    with "an anonymous user" do
      # it_raises ActiveRecord::RecordNotFound
      assert_status 404
    end

    with :is_superuser do
      it_assigns :section, :articles
      it_renders :template, 'pages/articles/index'
      it_does_not_cache_the_page
    end
  end

  describe 'GET to :index' do
    action { get :show, params_from('/an-unpublished-section/articles/an-article-in-an-unpublished-section') }
    
    with "an anonymous user" do
      # it_raises ActiveRecord::RecordNotFound
      assert_status 404
    end

    with :is_superuser do
      it_assigns :section, :article
      it_renders :template, 'pages/articles/show'
      it_does_not_cache_the_page
    end
  end
end