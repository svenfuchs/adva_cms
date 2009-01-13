require File.dirname(__FILE__) + '/../spec_helper'

describe "User views:" do
  include SpecViewHelper

  before :each do
    assigns[:site] = stub_site
    @user.stub!(:user).and_return stub_user

    template.stub!(:link_to_content).and_return 'link_to_content'
    template.stub!(:links_to_content_categories).and_return 'links_to_content_categories'
    template.stub!(:links_to_content_tags).and_return 'links_to_content_tags'
    template.stub!(:link_to_content_comments).and_return 'link_to_content_comments'
    template.stub!(:comment_path).and_return 'path/to/comment'

    template.stub!(:render).with hash_including(:partial => 'comments/list')
    template.stub!(:render).with hash_including(:partial => 'comments/form')
  end

  describe "new view" do
    before :each do
    end

    it "renders a form posting to /user" do
      render 'user/new'
      response.should have_tag('form[method=?][action=?]', 'post', '/user')
    end

    it "renders form fields for the user data" do
      render 'user/new'
      response.should have_tag('input[name=?]', 'user[email]')
      response.should have_tag('input[name=?]', 'user[password]')
      response.should have_tag('input[name=?]', 'user[first_name]')
      response.should have_tag('input[name=?]', 'user[last_name]')
      response.should have_tag('input[name=?]', 'user[homepage]')
    end
  end
end
