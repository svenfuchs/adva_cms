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