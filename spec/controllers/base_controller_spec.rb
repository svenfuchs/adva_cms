require File.dirname(__FILE__) + "/../spec_helper"

describe BaseController do
  include SpecControllerHelper

  before :each do
    scenario :empty_site
  end

  it "sets the current locale" do
    BaseController.before_filters.should include(:set_locale)
  end

  it "sets the current site" do
    BaseController.before_filters.should include(:set_site)
  end

  it "finds the current site from site_id param" do
    @controller.request.should_receive(:host_with_port)
    Site.should_receive(:find_by_host).and_return @site
    @controller.send :set_site
  end
end

describe BaseController, 'event integration' do
  it "responds to #trigger_event" do
    controller.should respond_to(:trigger_event)
  end
  
  describe "#guess_event_action" do
    before :each do
      Site.delete_all
      @site = Site.create :title => 'title', :name => 'name', :host => 'example.com'
    end
    
    it "returns :created for a new record" do
      controller.guess_event_action(Site.new).should == :created
    end
    
    it "returns :deleted for a frozen record" do
      @site.destroy
      controller.guess_event_action(@site).should == :deleted
    end
    
    it "defaults to :updated" do
      controller.guess_event_action(@site).should == :updated
    end
  end
  
  describe "#trigger_event_if_valid" do
    it "triggers an event if the given object is valid" do
      site = Site.new
      site.stub! :valid? => true
      Event.should_receive(:trigger).with(:site_created, site, controller)
      controller.trigger_event_if_valid site
    end
    
    it "does not trigger an event if the given object is not valid" do
      site = mock('site', :valid? => false)
      Event.should_not_receive(:trigger)
      controller.trigger_event_if_valid site
    end
  end
end