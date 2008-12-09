require File.expand_path(File.join(File.dirname(__FILE__), '../../../adva_cms/test', 'test_helper' ))

class SubscriptionsTest < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_newsletter
    login_as :admin
  end
  
  test 'admin opens index: should have no list, should have link to add subscribers' do
    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}/"

    assert_template 'admin/newsletters/show'
    click_link 'Subscribers'

    assert_template 'admin/newsletter_subscriptions/index'
    assert_select '.empty'
    assert_select '.empty>a', 'Add a new subscriber'
  end
end

class SubscriptionWithNoSiteUsersTest < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_newsletter
    login_as :superuser
    assert_equal 0, @site.users.size
  end

  test 'admin adds a news subscriber: should have no list, should show a link to add new user to the site' do
    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}/"

    assert_template 'admin/newsletters/show'
    click_link 'Add a new subscriber'
    
    assert_template 'admin/newsletter_subscriptions/new'
    assert_select '.empty'
    assert_select '.empty>a', 'Add a new user'
  end
end
