require File.expand_path(File.join(File.dirname(__FILE__), "..", "test_helper" ))

class AdvaNewsletterSignupIntegrationTest < ActionController::IntegrationTest
  def setup
    super
    @site = use_site! "site with newsletter"
    @newsletter = @site.newsletters.first
  end
  
  test "/signup should have newsletters list to subscribe" do
    visit_signup
    response.body.should have_tag("div#adva_newsletter_subscription")
    response.body.should have_tag("li > label", "newsletter title")
  end
  
  test "/signup should list only public (aka published) newsletters" do
    @newsletter.published = 0
    @newsletter.save
    visit_signup

    response.body.should have_tag("div#adva_newsletter_subscription")
    response.body.should_not have_tag("li > label", "newsletter title")
  end

  test "new user signups with subscription; should subscribe to newsletter" do
    visit_signup
    fill_in_all_fields
    check "newsletter title"
    click_button "Register"
  
    user = User.find_by_first_name("Newsletter test first name") 
    user.subscriptions.size.should == 1
  end
  
  test "new user signups without subscription; should not subscribe to newsletter" do
    visit_signup
    fill_in_all_fields
    uncheck "newsletter title"
    click_button "Register"

    user = User.find_by_first_name("Newsletter test first name")
    user.subscriptions.size.should == 0
  end
  
  private

    def visit_signup
      visit "/signup"
      assert_template "user/new"
    end

    def fill_in_all_fields
      fill_in :user_first_name, :with => "Newsletter test first name"
      fill_in :user_last_name,  :with => "Test last name"
      fill_in :user_homepage,   :with => "Test homepage"
      fill_in :user_email,      :with => "test@example.com"
      fill_in :user_password,   :with => "testpassword"
    end
end
