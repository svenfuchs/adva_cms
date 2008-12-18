require File.dirname(__FILE__) + '/../../spec_helper'
require 'base_helper'
require 'admin/comments_helper'

describe "Section views:" do
  include SpecViewHelper
  
  before :each do
    Site.delete_all
    @user = Factory :user
    assigns[:site]    = @site     = Factory(:site)
    assigns[:section] = @section  = Factory(:album, :site => @site)
    template.stub!(:current_user).and_return(@user)
    template.stub!(:admin_sections_path).and_return admin_sections_path(@site.id)
    template.extend BaseHelper
    template.extend Admin::CommentsHelper
  end
  
  describe "GET to new" do
    act! { render "admin/sections/new" }
    
    it "has an option to select album section type" do
      act!
      response.should have_tag("input#section_type_album")
    end
  end
  
  describe "GET to edit" do
    act! { render "admin/sections/edit" }
    
    it "has a form field for section_photos_per_page" do
      act!
      response.should have_tag("input#section_photos_per_page")
    end
  end
end