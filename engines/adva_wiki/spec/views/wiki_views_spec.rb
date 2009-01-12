require File.dirname(__FILE__) + '/../spec_helper'

describe "Wiki views:" do
  include SpecViewHelper

  before :each do
    assigns[:section] = @wiki = stub_wiki
    @wikipage = stub_wikipage
    @wikipages = stub_wikipages
    @comment = stub_comment

    Section.stub!(:find).and_return @wiki

    @wikipage.stub!(:approved_comments).and_return [@comment, @comment]

    template.stub!(:link_to_content).and_return 'link_to_content'
    template.stub!(:links_to_content_categories).and_return 'links_to_content_categories'
    template.stub!(:links_to_content_tags).and_return 'links_to_content_tags'
    template.stub!(:link_to_content_comments).and_return 'link_to_content_comments'
    template.stub!(:link_to_content_comments_count).and_return 'link_to_content_comments'
    template.stub!(:content_category_checkbox).and_return 'content_category_checkbox'

    template.stub!(:wiki_path).and_return 'path/to/wiki'
    template.stub!(:wikipages_path).and_return 'path/to/wikipages'
    template.stub!(:content_path).and_return 'path/to/content'
    template.stub!(:comment_path).and_return 'path/to/comment'
    template.stub!(:collection_title).and_return 'path/to/comment'
    template.stub!(:wiki_edit_links).and_return %w(some wiki edit links)
    template.stub!(:will_paginate).and_return 'will_paginate'
    template.stub!(:datetime_with_microformat).and_return 'Once upon a time ...'

    template.stub!(:render).with hash_including(:partial => 'comments/list')
    template.stub!(:render).with hash_including(:partial => 'comments/form')
    template.stub!(:render).with hash_including(:partial => 'footer')
  end

  describe "index view" do
    before :each do
      assigns[:wikipages] = @wikipages
    end

    it "displays a list of wikipages" do
      render "wiki/index"
      response.should have_tag('#wikipages tbody tr', 3)
    end
  end

  describe "show view" do
    before :each do
      assigns[:wikipage] = @wikipage
      assigns[:comment] = @comment
    end

    it "displays the wikipage" do
      render "wiki/show"
      response.should have_tag('div.entry', 1)
    end

    it "displays the wikipage's revision number" do
      @wikipage.should_receive(:version)
      render "wiki/show"
    end

    it "displays the wikipage's updated_at date" do
      @wikipage.should_receive(:updated_at).and_return Time.now
      render "wiki/show"
    end

    it "should link to the wikipage's last author" do
      @wikipage.should_receive(:author_link)
      render "wiki/show"
    end

    it "lists a group of wiki edit links" do
      template.should_receive(:wiki_edit_links).and_return %w(some wiki edit links)
      render "wiki/show"
    end

    it "wikifies the wikipage body" do
      template.should_receive(:wikify).with @wikipage.body
      render "wiki/show"
    end

    it "lists the wikipage's categories" do
      template.should_receive :links_to_content_categories
      render "wiki/show"
    end

    it "lists the wikipage's tags" do
      template.should_receive :links_to_content_tags
      render "wiki/show"
    end

    it "renders the comments/list partial" do
      template.should_receive(:render).with hash_including(:partial => 'comments/list')
      render "wiki/show"
    end

    describe "with a wikipage that accepts comments" do
      it "renders the comments/form partial" do
        @wikipage.should_receive(:accept_comments?).and_return true
        template.should_receive(:render).with hash_including(:partial => 'comments/form')
        render "wiki/show"
      end
    end

    describe "with a wikipage that does not accept comments" do
      it "should not render the comments/form partial" do
        @wikipage.should_receive(:accept_comments?).and_return false
        template.should_not_receive(:render).with hash_including(:partial => 'comments/form')
        render "wiki/show"
      end
    end
  end

  describe "the new view" do
    before :each do
      assigns[:wikipage] = @wikipage
      template.stub!(:wikipages_path).and_return '/wiki/pages'
      template.stub!(:render).with hash_including(:partial => 'form')
    end

    it "renders a form posting to /wiki/pages" do
      render "wiki/new"
      response.should have_tag('form[action=?][method=?]', '/wiki/pages', :post)
    end

    it "renders the form partial" do
      template.should_receive(:render).with hash_including(:partial => 'form')
      render "wiki/new"
    end
  end

  describe "the edit view" do
    before :each do
      assigns[:wikipage] = @wikipage
      template.stub!(:wikipage_path_with_home).and_return '/wiki/pages/a-wikipage'
      template.stub!(:render).with hash_including(:partial => 'form')
    end

    it "renders a form putting to /wiki/pages/a-wikipage" do
      render "wiki/edit"
      response.should have_tag('form[action=?]', '/wiki/pages/a-wikipage') do |form|
        form.should have_tag('input[name=?][value=?]', '_method', 'put')
      end
    end

    it "renders the form partial" do
      template.should_receive(:render).with hash_including(:partial => 'form')
      render "wiki/edit"
    end
  end

  describe "the form partial" do
    before :each do
      assigns[:wikipage] = @wikipage
      template.stub!(:render).with hash_including(:partial => 'categories/checkboxes')
      template.stub!(:f).and_return ActionView::Base.default_form_builder.new(:wikipage, @wikipage, template, {}, nil)
      template.stub!(:current_user).and_return stub_user
    end

    it "renders wikipage form fields" do
      render :partial => 'wiki/form'
      response.should have_tag('input[name=?]', 'wikipage[title]')
      response.should have_tag('textarea[name=?]', 'wikipage[body]')
    end

    describe "with the wikipage having categories" do
      it "renders the categories/checkboxes partial" do
        @wikipage.stub!(:categories).and_return [stub_category]
        template.should_receive(:content_category_checkbox).any_number_of_times.and_return('content_category_checkbox')
        render :partial => 'wiki/form'
        response.body.should =~ /content_category_checkbox/
      end
    end

    describe "with the wikipage having no categories" do
      it "does not render the categories/checkboxes partial" do
        @wikipage.stub!(:categories).and_return []
        render :partial => 'wiki/form'
        response.should_not have_tag('input[type=?][name=?]', 'checkbox', 'wikipage[category_ids][]')
      end
    end

    describe "with a user currently logged in" do
      it "does not render a name field" do
        render :partial => 'wiki/form'
        response.should_not have_tag('input[name=?]', 'user[name]')
      end
    end

    describe "with no user currently logged in" do
      it "renders a name field" do
        template.stub!(:current_user).and_return User.anonymous
        render :partial => 'wiki/form'
        response.should have_tag('input[name=?]', 'user[name]')
      end
    end
    
    describe "when rendering the new view" do
      it "does not render Delete and Cancel links" do
        @wikipage.stub!(:new_record?).and_return true
        template.should_not_receive(:t).with(:'adva.common.delete')
        template.should_not_receive(:t).with(:'adva.common.cancel')
        render :partial => 'wiki/form'
      end
    end
    
    describe "with the wikipage being the home page" do
      it "does not render the Delete link but does render the cancel link" do
        @wikipage.stub!(:home?).and_return true
        @wikipage.stub!(:new_record?).and_return false
        template.should_not_receive(:t).with(:'adva.common.delete')
        template.should_receive(:t).with(:'adva.common.cancel')
        render :partial => 'wiki/form'
      end
    end
  end
end
