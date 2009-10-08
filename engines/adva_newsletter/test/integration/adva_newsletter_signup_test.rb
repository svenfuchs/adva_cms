require File.expand_path(File.join(File.dirname(__FILE__), "..", "test_helper" ))

class AdvaNewsletterSignupIntegrationTest < ActionController::IntegrationTest
  def setup
    super
    @site = use_site! "site with newsletter"
    @newsletter = @site.newsletters.find_by_title("newsletter title")
  end

  # test "/signup should have newsletters list to subscribe" do
  #   visit_signup
  #   assert_select '*', /newsletter title/
  # end

  test "/signup should list only public (aka published) newsletters" do
    @newsletter.published = 0
    @newsletter.save
    visit_signup
    assert response.body !~ /newsletter title/
  end

  test "new user signups with subscription; should subscribe to newsletter" do
    visit_signup
    fill_in_all_fields
    check "newsletter title"
    click_button "register"

    user = User.find_by_first_name("Newsletter test first name")
    user.subscriptions.size.should == 1
  end

  test "new user signups without subscription; should not subscribe to newsletter" do
    visit_signup
    fill_in_all_fields
    click_button "register"

    user = User.find_by_first_name("Newsletter test first name")
    user.subscriptions.size.should == 0
  end

  private

    def visit_signup
      visit "/signup"
      assert_template "user/new"
    end

    def fill_in_all_fields
      fill_in 'user_first_name', :with => "Newsletter test first name"
      fill_in 'user_email',      :with => "test@example.com"
      fill_in 'user_password',   :with => "testpassword"

      @site.newsletters.each do |newsletter|
        uncheck "user_newsletter_subscriptions_#{newsletter.id}"
      end
    end
end
