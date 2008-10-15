require File.dirname(__FILE__) + '/../../spec_helper'

describe "Admin::Sections Views:" do
  include SpecViewHelper

  before :each do
    assigns[:site] = @site = stub_site
    assigns[:section] = @section = stub_section

    set_resource_paths :section, '/admin/'
    template.stub!(:admin_sections_path).and_return @collection_path
    template.stub!(:admin_section_path).and_return @member_path

    template.stub!(:filter_options).and_return []
    template.stub!(:comment_expiration_options).and_return []

    template.stub_render hash_including(:partial => 'form')
  end

  describe "the :show view" do
    it "displays a form to edit settings (putting to :update)" do
      render "admin/sections/show"
      response.should have_tag('form[action=?]', @member_path) do
        with_tag 'input[name=?][value=?]', '_method', 'put'
      end
    end

    it "renders the form partial" do
      template.expect_render hash_including(:partial => 'form')
      render "admin/sections/show"
    end
  end

  describe "the :new view" do
    it "displays a form to add a new section" do
      render "admin/sections/new"
      response.should have_tag('form[action=?]', @collection_path) do
        with_tag "input[name='section[type]']", Section.types.size
        with_tag "input[name='section[title]']"
      end
    end
  end

  describe "the form partial" do
    before :each do
      template.stub_render hash_including(:partial => 'admin/sections/settings/permissions')
      template.stub!(:f).and_return ActionView::Base.default_form_builder.new(:section, @section, template, {}, nil)
    end

    it "renders the admin/sections/settings/section partial if the section is a Section" do
      template.expect_render hash_including(:partial => 'admin/sections/settings/section')
      render "admin/sections/_form"
    end

    it "renders the admin/sections/settings/blog partial if the section is a Blog" do
      assigns[:section] = stub_blog
      template.expect_render hash_including(:partial => 'admin/sections/settings/blog')
      render "admin/sections/_form"
    end

    it "renders the admin/sections/settings/permissions partial" do
      template.expect_render hash_including(:partial => 'admin/sections/settings/permissions')
      render "admin/sections/_form"
    end
  end

  describe "the section partial" do
    before :each do
      @section.stub!(:children).and_return(@sections)
      template.stub!(:section).and_return(@section)
    end

    it "renders itself for nested sections" do
      template.expect_render hash_including(:partial => 'section')
      render "admin/sections/_section"
    end
  end
end
