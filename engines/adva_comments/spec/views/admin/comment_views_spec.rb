require File.dirname(__FILE__) + '/../../spec_helper'

describe "Admin::Comments:" do
  include SpecViewHelper

  before :each do
    @comment = stub_comment
    @comments = stub_comments

    set_resource_paths :comment, '/admin/sites/1/'
    @admin_comment_returning_path = "#{@member_path}?return_to=here"

    template.stub!(:admin_comment_path).and_return @member_path
    template.stub!(:admin_comments_path).and_return @collection_path
    template.stub!(:admin_comment_returning_path).and_return @admin_comment_returning_path
    template.stub!(:edit_admin_comment_path).and_return @edit_member_path

    template.stub!(:will_paginate)
    template.stub!(:link_to_content_comment).and_return '<a href="path/to/content#comment-id"></a>'
    template.stub!(:link_to_admin_object).and_return '<a href="path/to/admin/object"></a>'
  end

  describe "the index view" do
    before :each do
      assigns[:comments] = @comments
      assigns[:contents] = []
      template.stub_render hash_including(:partial => 'comment')
    end

    act! { render "admin/comments/index" }

    it "should display a filter for filtering the comments list" do
      result[:filter].should have_tag('select[id=?]', 'filterlist')
    end

    it "should display a list of comments" do
      result.should have_tag('ul[id=?]', 'comments_list')
    end

    it "should render the comment partial" do
      template.expect_render(hash_including(:partial => 'comment')).at_least(@comments.size).times
      act!
    end
  end

  describe "the comment partial" do
    before :each do
      template.stub!(:comment).and_return @comment
    end

    act! { render "admin/comments/_comment" }

    it "displays the comment body" do
      result.body.should =~ /body/
    end

    it "displays the comment body with tags stripped" do
      template.should_receive(:strip_tags)
      act!
    end

    describe "with an unapproved comment" do
      before :each do
        @comment.stub!(:approved?).and_return false
      end

      it "displays a link for approving the comment" do
        result.should have_tag('a[href=?]', @member_path, :text => 'Approve')
      end
    end

    describe "with an approved comment" do
      before :each do
        @comment.stub!(:approved?).and_return true
      end

      it "displays a link for unapproving the comment" do
        result.should have_tag('a[href=?]', @member_path, :text => 'Unapprove')
      end

      # it "displays a link for replying to the comment" do
      #   result.should have_tag('a', :text => 'Reply')
      # end
    end

    it "displays a link to the comment on the frontend view" do
      result.should have_tag('a[href=?]', 'path/to/content#comment-id')
    end

    it "displays a link for editing the comment" do
      result.should have_tag('a[href=?]', @edit_member_path, :text => 'Edit')
    end

    it "displays a link for deleting the comment" do
      result.should have_tag('a[href=?]', @admin_comment_returning_path, :text => 'Delete')
    end
  end
end