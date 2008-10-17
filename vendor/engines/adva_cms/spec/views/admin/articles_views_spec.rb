require File.dirname(__FILE__) + '/../../spec_helper'
require 'base_helper'

describe "Admin::Articles:" do
  include SpecViewHelper

  before :each do
    @article = stub_article
    @articles = stub_articles

    assigns[:section] = @section = stub_section
    assigns[:site] = @site = stub_site
    assigns[:categories] = @categories = stub_categories

    set_resource_paths :article, '/admin/sites/1/sections/1/'

    template.stub!(:admin_articles_path).and_return(@collection_path)
    template.stub!(:admin_article_path).and_return(@member_path)
    template.stub!(:new_admin_article_path).and_return @new_member_path
    template.stub!(:edit_admin_article_path).and_return(@edit_member_path)
    template.stub!(:will_paginate)

    template.stub_render hash_including(:partial => 'options')
    template.stub_render hash_including(:partial => 'categories/checkboxes')
    template.stub_render hash_including(:partial => 'admin/assets/widget/widget')

    (class << template; self; end).class_eval do
      include BaseHelper
    end
  end

  describe "the index view" do
    before :each do
      assigns[:articles] = stub_articles
    end

    it "should display a list of articles" do
      template.stub_render :partial => 'article', :collection => stub_articles
      render "admin/articles/index"
      response.should have_tag('table[id=articles]')
    end

    it "should render the article partial" do
      template.expect_render :partial => 'article', :collection => stub_articles
      render "admin/articles/index"
    end
  end

  describe "the new view" do
    before :each do
      assigns[:article] = @article
    end

    it "should render the form partial" do
      template.expect_render hash_including(:partial => 'form')
      render "admin/articles/new"
    end
  end

  describe "the edit view" do
    before :each do
      assigns[:article] = @article
    end

    it "should render the form partial" do
      template.stub! :link_to
      template.stub! :content_url
      template.expect_render hash_including(:partial => 'form')
      render "admin/articles/edit"
    end
  end

  describe "the form partial" do
    before :each do
      assigns[:article] = @article
      @article.stub!(:has_excerpt?).and_return true
      @article.stub!(:draft?).and_return true
      template.stub!(:f).and_return ActionView::Base.default_form_builder.new(:article, @article, template, {}, nil)
    end

    it "should render the options partial to the sidebar" do
      template.expect_render hash_including(:partial => 'options')
      render "admin/articles/_form"
    end

    it "should render the article form fields" do
      render "admin/articles/_form"
      response.should have_tag('input[name=?]', 'article[title]')
      response.should have_tag('textarea[name=?]', 'article[body]')
    end

    it "should work with taglist containing double quotes" #do
    #  @article.stub!(:tag_list).and_return(["foo bar"])
    #  response.should have_tag('input#article_tag_list[value=?]', "foo bar")
    #end

    it "should have the draft checkbox check when assigned article is a draft" do
      @article.stub!(:draft?).and_return(true)
      render "admin/articles/_form"
      response.should have_tag('input[type=?][name=?][checked=checked]', 'checkbox', 'draft')
    end

    it "should have the draft checkbox check when assigned article is not a draft" do
      @article.stub!(:draft?).and_return(false)
      render "admin/articles/_form"
      response.should have_tag('input[type=?][name=?]', 'checkbox', 'draft')
      response.should_not have_tag('input[type=?][name=?][checked=checked]', 'checkbox', 'draft')
    end
  end

  describe "the options partial" do
    before :each do
      assigns[:article] = @article

      @article.stub!(:assets).and_return []
      @site.stub!(:assets).and_return mock('assets_proxy', :recent => [])
      template.stub!(:bucket_assets)

      template.stub!(:f).and_return ActionView::Base.default_form_builder.new(:article, @article, template, {}, nil)
      template.stub!(:filter_options).and_return []
      template.stub!(:comment_expiration_options).and_return []
      template.stub!(:author_options).and_return([["current user"], [1]])
    end

    it "should render the categories/checkboxes partial" do
      template.expect_render hash_including(:partial => 'categories/checkboxes')
      render "admin/articles/_options"
    end

    it "should render the assets/widget/widget partial" do
      template.expect_render hash_including(:partial => 'admin/assets/widget/widget')
      render "admin/articles/_options"
    end

    it "should have the sele  ctbox for selecting an author for an article" do
      render "admin/articles/_options"
      response.should have_tag('select[id=?]', 'article_author')
    end
  end
  
  describe "the article partial" do
    before :each do
      template.stub!(:article).and_return(@article)
      template.stub! :link_to
      template.stub! :published_at_formatted
      template.stub! :content_path
    end
    
    it "should check if article has comments enabled" do
      @article.should_receive(:accept_comments?).and_return false
      render "admin/articles/_article"
    end
  end
end
