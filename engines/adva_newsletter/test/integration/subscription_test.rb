require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

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
  
  test 'admin adds subscriber: should add new subscriber to the newsletter and total subscribers should be 1' do
    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}/"

    assert_template 'admin/newsletters/show'
    click_link 'Add a new subscriber'
    
    assert_template 'admin/newsletter_subscriptions/new'
    select 'John Doe'
    click_button 'Add'

    assert_template 'admin/newsletter_subscriptions/index'
    assert_content 'John Doe'
    assert_content 'Total subscribers: 1'

    # admin tries to add same subscriber second time: should show link add new user to the site
    click_link 'Add a new subscriber'
    
    assert_template 'admin/newsletter_subscriptions/new'
    assert_content 'Site does not have any available user'
    click_link 'Add a new user'
    
    # admin unsubscribe John Doe 
    # TODO: bring on selenium test for that
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
