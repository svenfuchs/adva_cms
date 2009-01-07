require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class TopicsWithoutBoards < ActionController::IntegrationTest
  def setup
    factory_scenario  :site_with_forum
    login_as          :admin
  end
  
  def test_an_admin_creates_a_new_topic
     # Go to section
    get forum_path(@forum)
    
    # Admin clicks link to go to the board
    click_link 'Post one now'
    
    assert Topic.count == 0
    assert_template 'topics/new'
    
    fill_in       'Title',       :with => 'Test topic'
    fill_in       'Body',        :with => 'Test topic description'
    click_button  'Post topic'
    
    assert Topic.count == 1
    
    assert_template 'topics/show'
  end
end