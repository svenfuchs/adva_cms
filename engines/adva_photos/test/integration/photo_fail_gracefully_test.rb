require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class PhotoFailGracefullyTest < ActionController::IntegrationTest
  def setup
    super
    @site = use_site! 'site with pages'
  end
  
  test 'fails gracefully when user tries to sort photos by non existant tag' do
    visit '/an-album/tags/null'
    display_album
  end
  
  test 'fails gracefully when user tries to sort photos by non existant set' do
    visit '/an-album/sets/null'
    display_album
  end
  
  test 'fails gracefully when user tries to find non existant photo' do
    visit '/an-album/photos/abc'
    redirect_back_to_album
  end
  
  def visit(path)
    get path
  end
  
  def redirect_back_to_album
    assert_redirected_to '/an-album'
  end
  
  def display_album
    assert_template 'albums/index'
  end
end