require File.expand_path(File.join(File.dirname(__FILE__), '../../../adva_cms/test', 'test_helper' ))

class NoIssuesTest < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_newsletter
    login_as :admin
  end
  
  test 'admin submits an EMPTY issue: should see validation warnings' do

    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}"

    assert_template 'admin/newsletters/show'
    click_link 'Create a new issue'

    assert_template 'admin/issues/new'
    fill_in :issue_title, :with => nil
    fill_in :issue_body, :with => nil
    click_button 'Save'

    assert_template 'admin/issues/new'
    assert_select '.field_with_error'
  end
  
  test 'admin submits a DRAFT issue: should be success and show new issue' do
    
    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}/issues/new"

    assert_template 'admin/issues/new'
    fill_in :issue_title, :with => 'draft issue title'
    fill_in :issue_body, :with => 'draft issue body'
    click_button 'Save'

    assert_template 'admin/issues/show'
    assert_select '#issue' do
      assert_select 'h2', 'draft issue title'
      assert_select 'p', 'draft issue body'
    end
  end
end

class IssuesTest < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_newsletter_and_issue
    login_as :admin
  end
  
  test 'admin EDITS issue: should be success' do
    
    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}/issues/#{@issue.id}"

    assert_template 'admin/issues/show'
    click_link 'Edit'

    assert_template 'admin/issues/edit'
    fill_in :issue_title, :with => 'EDITED issue title'
    fill_in :issue_body, :with => 'EDITED issue body'
    click_button 'Save'

    assert_template 'admin/issues/show'
    assert_flash 'Issue has been updated successfully'
    assert_select '#issue' do
      assert_select 'h2', 'EDITED issue title'
      assert_select 'p', 'EDITED issue body'
    end
  end
end  

class IssuesWithSubscriptionTest < ActionController::IntegrationTest
  def setup
    factory_scenario :site_with_newsletter_and_issue
    login_as :admin
    @other_user = Factory :other_user

    # TODO: perhaps factory has some better way for poly
    @subscription = Subscription.new(:user_id => @other_user.id)
    @subscription.subscribable_id = 1
    @subscription.subscribable_type = 'Newsletter'
    @subscription.save
    visit "/admin/sites/#{@site.id}/newsletters/#{@newsletter.id}/issues/#{@issue.id}/edit"
    assert_template 'admin/issues/edit'
  end

  test 'admin DELIVERS NOW: should be added to delivery queue (currently delivery is mocked)' do
    uncheck 'draft'
    click_button 'Deliver now'

    assert_template 'admin/issues/show'
    assert_flash 'Issue has been added to the delivery queue'
  end
  
  test 'admin DELIVERS WITH DELAY: should be added to delivery queque with delay (deliver mocked)' do
    uncheck 'draft'
    click_button 'Deliver later'

    assert_template 'admin/issues/show'
    assert_flash 'Issue with delayed delivery has been added to the queue'
  end

  test 'admin submits TEST DELIVERY: test delivery should be added to the queue with myself as the only recipent (deliver mocked)' do
    uncheck 'draft'
    check 'test_delivery'
    click_button 'Deliver now'

    assert_template 'admin/issues/show'
    assert_flash 'Test delivery has been added to the queue'
  end
  
  test 'avoid bug: admin submits TEST DELIVERY with DRAFT checked: should not deliver, should make normal update only' do
    check 'draft'
    check 'test_delivery'
    click_button 'Save'

    assert_template 'admin/issues/show'
    assert_flash 'Issue has been updated successfully'
  end
  
end

#TODO move to more global place
def assert_flash(message)
  regexp = Regexp.new(message.gsub(' ', '\\\+'))
  assert cookies['flash'] =~ regexp,
    "Flash message is wrong or missing:\nwe should get flash message: #{message}\nin cookie: #{regexp}\nwe got: #{cookies['flash']}"
end
