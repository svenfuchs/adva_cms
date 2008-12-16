require File.dirname(__FILE__) + '/../spec_helper'

describe "Section views:" do
  include SpecViewHelper
  
  before :each do
    Site.delete_all
    @user = Factory :user
    assigns[:site]    = @site     = Factory(:site)
    assigns[:section] = @section  = @site.sections.build(Factory.attributes_for(:section))
    template.stub!(:current_user).and_return(@user)
    template.stub!(:admin_sections_path).and_return admin_sections_path(@site.id)
  end
  
  describe "GET to new" do
    act! { render "admin/sections/new" }
    
    it "has an option to select album section type" do
      act!
      response.should have_tag("input#section_type_album")
    end
  end
end