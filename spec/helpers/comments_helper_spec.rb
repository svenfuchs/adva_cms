require File.dirname(__FILE__) + '/../spec_helper'

describe CommentsHelper do
  include Stubby
  include UrlMatchers
  include CommentsHelper
  
  before :each do
    scenario :site, :section, :article, :comment
  end
  
  it 'should have complete specs'
  
  describe "the admin_comment_path helper" do
    it "calls admin_site_comment_path helper" do
      should_receive(:admin_site_comments_path)
      admin_comments_path
    end
    
    describe "with no :section_id param given" do
      describe "and with no :content_id param given" do
        it "returns the admin_site_comment_path with no further params" do
          stub!(:params).and_return :site_id => 1
          admin_comments_path(@site).should_not have_parameters
        end
      end
      
      describe "and with a :content_id param given" do
        it "returns the admin_site_comment_path with the :content_id param" do
          stub!(:params).and_return :site_id => 1, :content_id => 1
          admin_comments_path(@site).should have_parameters(:content_id)
        end
      end
    end

    describe "with a :section_id param given" do
      describe "and with no :content_id param given" do
        it "returns the admin_site_comment_path with the :section_id param" do
          stub!(:params).and_return :site_id => 1, :section_id => 1
          admin_comments_path(@site).should have_parameters(:section_id)
        end
      end
      
      describe "and with a :content_id param given" do
        it "returns the admin_site_comment_path with the :content_id param" do
          stub!(:params).and_return :site_id => 1, :section_id => 1, :content_id => 1
          admin_comments_path(@site).should have_parameters(:content_id)
        end
      end
    end
  end
end