require File.expand_path(File.join(File.dirname(__FILE__), "..", "test_helper" ))

class SubscriptionIntegrationTest < ActionController::IntegrationTest
  def setup
    super
    @site = use_site! "site with newsletter"
    @newsletter = @site.newsletters.first
    Subscription.destroy_all
  end
  
  test "admin manages subscriptions" do
    login_as_admin
    visit_subscriptions
    add_site_user
    add_subscriber
    try_to_add_same_subscriber
    unsubscribe
  end
  
private

  def visit_subscriptions
    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}/subscriptions"

    assert_template "admin/newsletter_subscriptions/index"
    response.body.should have_tag ".empty>a", "Add a new subscriber"
  end
  
  def add_site_user
    @site.users.destroy_all

    assert_template "admin/newsletter_subscriptions/index"
    click_link "Add a new subscriber"

    assert_template "admin/newsletter_subscriptions/new"
    response.body.should have_tag ".empty", /Site does not have any available user/
    response.body.should have_tag ".empty>a", "Add a new user" 
    
    # adding site user is out of scope of this test
    @site.users << User.find_by_first_name("user")
    
    click_link "Subscribers"
  end
  
  def add_subscriber
    @site.users.should_not == []

    assert_template "admin/newsletter_subscriptions/index"
    click_link "Add a new subscriber"

    assert_template "admin/newsletter_subscriptions/new"
    select "user"
    click_button "Add"

    assert_template "admin/newsletter_subscriptions/index"
    response.body.should have_tag "td>a", "user"
    response.body.should have_tag "p", "Total subscribers: 1"
  end

  def try_to_add_same_subscriber
    assert_template "admin/newsletter_subscriptions/index"
    click_link "Add a new subscriber"
    
    assert_template "admin/newsletter_subscriptions/new"
    response.body.should have_tag ".empty", /Site does not have any available user/
    response.body.should have_tag ".empty>a", "Add a new user"
  end
  
  def unsubscribe
    # TODO: bring on selenium test for that
  end
end
