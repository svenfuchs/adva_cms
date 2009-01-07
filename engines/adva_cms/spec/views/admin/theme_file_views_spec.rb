require File.dirname(__FILE__) + '/../../spec_helper'

describe "Admin::Themes:" do
  include SpecViewHelper

  before :each do
    stub_scenario :empty_site, :theme_with_files
    assigns[:site] = @site
    assigns[:theme] = @theme
    assigns[:file] = @file

    @admin_theme_files_path = '/admin/sites/1/themes/theme-1/files'
    @admin_theme_file_path = '/admin/sites/1/themes/theme-1/files/templates-foo-html-erb'
    @new_admin_theme_file_path = '/admin/sites/1/themes/theme-1/files/new'

    template.stub!(:admin_theme_files_path).and_return @admin_theme_files_path
    template.stub!(:admin_theme_file_path).and_return @admin_theme_file_path
    template.stub!(:new_admin_theme_file_path).and_return @new_admin_theme_file_path
    template.stub!(:theme_image_tag).and_return 'theme_image_tag'
  end

  describe "the :show view" do
    before :each do
      template.stub!(:render).with hash_including(:partial => 'form')
    end

    it "renders a form to edit the file" do
      render "admin/theme_files/show"
      response.should have_tag('form[action=?]', @admin_theme_file_path) do
        with_tag 'input[name=?][value=?]', '_method', 'put'
      end
    end

    it "renders the form partial" do
      template.should_receive(:render).with hash_including(:partial => 'form')
      render "admin/theme_files/show"
    end
  end

  describe "the :new view" do
    before :each do
      template.stub!(:render).with hash_including(:partial => 'form')
    end

    it "renders a form to add a new file" do
      render "admin/theme_files/new"
      response.should have_tag('form[action=?][method=?]', @admin_theme_files_path, :post)
    end

    it "renders the form partial" do
      template.should_receive(:render).with hash_including(:partial => 'form')
      render "admin/theme_files/new"
    end
  end

  describe "the form partial" do
    before :each do
      template.stub!(:f).and_return ActionView::Base.default_form_builder.new(:file, @file, template, {}, nil)
    end

    it "renders a file localpath field" do
      render "admin/theme_files/_form"
      response.should have_tag('input[name=?]', 'file[localpath]')
    end

    it "renders a file data textarea when the file has text content" do
      render "admin/theme_files/_form"
      response.should have_tag('textarea[name=?]', 'file[data]')
    end

    it "does not render a file data textarea when the file does not have text content" do
      @file.stub!(:text?).and_return false
      render "admin/theme_files/_form"
      response.should_not have_tag('textarea[name=?]', 'file[data]')
    end
  end

  describe "the files partial" do
    before :each do
    end
    
    # TODO not true right now
    # it "displays a link to theme_file/new" do
    #   render "admin/theme_files/_files"
    #   response.should have_tag('a[href=?]', @new_admin_theme_file_path)
    # end
    # 
    # it "renders a form for uploading a new file" do
    #   render "admin/theme_files/_files"
    #   response.should have_tag('form[action=?][enctype=?]', @admin_theme_files_path, 'multipart/form-data')
    # end

    it "lists the existing template files" do
      render "admin/theme_files/_files"
      response.should have_tag('h3', 'Templates')
    end

    it "lists the existing asset files" do
      render "admin/theme_files/_files"
      response.should have_tag('h3', 'Assets')
    end

    it "lists the existing other files" do
      render "admin/theme_files/_files"
      response.should have_tag('h3', 'Others')
    end

    it "links to the existing files' :edit actions" do
      render "admin/theme_files/_files"
      response.should have_tag('a[href=?]', @admin_theme_file_path, @file.localpath)
    end
  end
end
