require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

module IntegrationTests
  class AnonymousLoginTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with pages'
      @site.update_attributes! :permissions => { 'create comment' => 'anonymous' }
    end
  
    test "After posting a comment an anonymous is recognized by the system (aka anonymous login)" do
      post_a_section_comment_as_anonymous
      check_logged_in_as_anonymous
      visit '/'
      check_logged_in_as_anonymous
    end
    
    def post_a_section_comment_as_anonymous
      visit '/articles/a-page-article'
      fill_in "user_name", :with => "John Doe"
      fill_in "user_email", :with => "john@example.com"
      fill_in "comment_body", :with => "What a nice article!"
      click_button "Submit comment"
    end
    
    def check_logged_in_as_anonymous
      # the user is logged in as an anonymous user
      current_user.should_not be_nil
      current_user.anonymous?.should be_true
      
      # a cookie containing the user id and indicating the anonymous login was set
      cookies['aid'].should == current_user.id.to_s 
    end
    
    def current_user
      controller.current_user
    end
  end
end