require File.dirname(__FILE__) + '/../../spec_helper'

describe "Photo views:" do
  include SpecViewHelper
  
  before :each do
    Site.delete_all
    @site   = Factory :site
    @album  = Factory :album, :site => @site
    @user   = Factory :user
    @set    = Factory :set, :section => @album
    @album.sets.stub!(:roots).and_return [@set]
    assigns[:site]    = @site
    assigns[:section] = @album
    assigns[:sets]    = @album.sets.roots
    assigns[:set]     = @album.sets.roots.first
    
    template.stub!(:f).and_return ActionView::Base.default_form_builder.new(:set, @set, template, {}, nil)
  end
    
  describe "GET to index" do
    describe "with array of sets" do
      before :each do
        @album.sets.roots.stub!(:total_entries).and_return(10)
        template.stub!(:render).with hash_including(:set)
      end
      act! { render "admin/sets/index" }
    
      it "should show total of set entries in album" do
        act!
        response.should have_tag('p.total')
      end
    
      it "should have list of sets" do
        act!
        response.should have_tag('table#sets.list')
      end
    
      it "should render set partial" do
        template.should_receive(:render).with hash_including(:partial => 'set')
        act!
      end
    end
    
    describe "with empty array" do
      before :each do
        assigns[:sets] = []
      end
      act! { render "admin/sets/index" }
    
      it "should have an empty list" do
        act!
        response.should have_tag('div.empty')
      end
      
      it "has a link to create a new set" do
        act!
        response.should have_tag("a[href=?]", new_admin_set_path(@site, @album))
      end
    end
  end
  
  describe "GET to new" do
    act! { render "admin/sets/new" }
    
    it "should have the cancel link" do
      act!
      response.should have_tag('a[href=?]', "/admin/sites/#{@site.id}/sections/#{@album.id}/sets")
    end
    
    it "should have the form button for creating the set" do
      act!
      response.should have_tag('input[name=?]', 'commit')
    end
    
    it "should have the title input label" do
      act!
      response.should have_tag('label[for=?]', 'set_title')
    end
    
    it "should have the title input field" do
      act!
      response.should have_tag('input[name=?]', 'set[title]')
    end
  end
  
  describe "GET to edit" do
    act! { render "admin/sets/edit" }
    
    it "should have the cancel link" do
      act!
      response.should have_tag('a[href=?]', "/admin/sites/#{@site.id}/sections/#{@album.id}/sets")
    end
    
    it "should have the form button for updating the set" do
      act!
      response.should have_tag('input[name=?]', 'commit')
    end
    
    it "should have the title input label" do
      act!
      response.should have_tag('label[for=?]', 'set_title')
    end
    
    it "should have the title input field" do
      act!
      response.should have_tag('input[name=?]', 'set[title]')
    end
    
    it "should have the permalink input label" do
      act!
      response.should have_tag('label[for=?]', 'set_permalink')
    end
    
    it "should have the permalink input field" do
      act!
      response.should have_tag('input[name=?]', 'set[permalink]')
    end
  end
  
  describe "_set" do
    before :each do
      template.stub!(:object).and_return(@set)
    end
    act! { render 'admin/sets/_set' }
    
    it "should have link to edit set" do
      act!
      response.should have_tag('a[href=?]', edit_admin_set_path(@site, @album, @set))
    end
    
    it "should have link to delete set" do
      act!
      response.should have_tag('a.delete')
    end
  end
end