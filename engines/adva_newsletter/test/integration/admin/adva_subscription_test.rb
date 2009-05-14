require File.expand_path(File.join(File.dirname(__FILE__), "../..", "test_helper" ))

class AdvaSubscriptionIntegrationTest < ActionController::IntegrationTest
  def setup
    super
    @site = use_site! "site with newsletter"
    @newsletter = @site.newsletters.first
    login_as_admin
    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}/subscriptions"
    assert_template "admin/newsletter_subscriptions/index"
  end

  test "visit subscriptions" do
    Adva::Subscription.destroy_all
    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}/subscriptions"

    assert_template "admin/newsletter_subscriptions/index"
    response.body.should have_tag(".empty > a", /Create one now/)
  end

  test "add subscriber" do
    add_site_user
    click_link "New"

    assert_template "admin/newsletter_subscriptions/new"
    select @site.users.last.name
    click_button "Add"

    assert_template "admin/newsletter_subscriptions/index"
    # response.body.should have_tag("th[class=total]", "Total subscribers: 1")
    response.body.should have_tag("td>a", "newsletter site user")
  end

  test "try to add same subscriber" do
    assert_template "admin/newsletter_subscriptions/index"
    click_link "New"

    assert_template "admin/newsletter_subscriptions/new"
    response.body.should have_tag(".empty", /no users available/)
  end

  test "unsubscribe" do
    # TODO: bring on selenium test for that
  end

private
  def add_site_user
    site_user = User.create! :first_name => 'newsletter site user',
                             :email => 'newsletter-site-user@example.com',
                             :password => 'password',
                             :verified_at => Time.now
    site_user.should_not == nil
    @site.users << site_user
    @site.save!
  end
end
