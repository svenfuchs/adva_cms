require File.dirname(__FILE__) + '/../spec_helper'

describe "Comment views:" do
  include SpecViewHelper
  include ContentHelper

  before :each do
    assigns[:site] = @site = stub_site
    assigns[:comment] = @comment = stub_comment
    assigns[:commentable] = @article = stub_article

    @comment.stub!(:commentable).and_return @article

    template.stub!(:has_permission?).and_return false
    template.stub!(:link_to_content).and_return 'link_to_content'
    template.stub!(:datetime_with_microformat).and_return 'Once upon a time ...'

    template.stub!(:render).with hash_including(:partial => 'comments/comment')
    template.stub!(:render).with hash_including(:partial => 'comments/form')
  end

  describe "show view" do
    before :each do
      @comment.stub!(:approved?).and_return false
    end
    act! { render "comments/show" }

    it 'renders the comment partial' do
      template.should_receive(:render).with hash_including(:partial => 'comments/comment')
      act!
    end

    it "checks if the user has the permission to update the comment" do
      template.should_receive(:has_permission?).with(:update, :comment)
      act!
    end

    it 'renders the comment form partial when the comment is not approved and the user has the permission to update the comment' do
      template.stub!(:has_permission?).with(:update, :comment).and_return true
      template.should_receive(:render).with hash_including(:partial => 'comments/form')
      act!
    end

    it 'does not render the comment form partial when the user has no permission to update the comment' do
      template.stub!(:has_permission?).with(:update, :comment).and_return false
      template.should_receive(:render).with(hash_including(:partial => 'comments/form')).never
      act!
    end

    it 'does not render the comment form partial when comment is already approved' do
      @comment.stub!(:approved?).and_return true
      template.should_receive(:render).with(hash_including(:partial => 'comments/form')).never
      act!
    end
  end

  describe "the comment partial" do
    before :each do
      template.stub!(:comment).and_return @comment
    end
    act! { render "comments/_comment" }

    it "displays the comment body" do
      result.body.should =~ /body/
    end

    it "displays a message when the comment is not approved yet" do
      @comment.stub!(:approved?).and_return false
      result.body.should =~ /under review/
    end
  end

  describe "the comment form partial" do
    it "should be specified"
  end
end