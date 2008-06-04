require File.dirname(__FILE__) + '/../spec_helper'

describe "Account views:" do
  include SpecViewHelper
  
  before :each do
    scenario :site, :user

    assigns[:site] = @site
    @account.stub!(:user).and_return @user

    template.stub!(:link_to_content).and_return 'link_to_content'
    template.stub!(:links_to_content_categories).and_return 'links_to_content_categories'
    template.stub!(:links_to_content_tags).and_return 'links_to_content_tags'
    template.stub!(:link_to_content_comments).and_return 'link_to_content_comments'
    template.stub!(:comment_path).and_return 'path/to/comment'
    
    template.stub_render hash_including(:partial => 'comments/list')    
    template.stub_render hash_including(:partial => 'comments/form')    
  end
  
  describe "new view" do
    before :each do
    end
    
    it "renders a form posting to /account" do
      render 'account/new'
      response.should have_tag('form[method=?][action=?]', 'post', '/account')
    end
    
    it "renders form fields for the account data" do
      render 'account/new'
      response.should have_tag('input[name=?]', 'user[login]')
    end

    it "renders form fields for the account's user data" do
      render 'account/new'
      response.should have_tag('input[name=?]', 'user[name]')
    end
  end
end