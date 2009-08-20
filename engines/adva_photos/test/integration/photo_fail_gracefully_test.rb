require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class PhotoFailGracefullyTest < ActionController::IntegrationTest
  def setup
    super
    @site = use_site! 'site with pages'
  end

  test 'fails gracefully when user tries to sort photos by non existant tag' do
    visit '/an-album/tags/null'
    assert_template 'albums/index'
  end

  test 'fails gracefully when user tries to sort photos by non existant set' do
    visit '/an-album/sets/null'
    assert_template 'albums/index'
  end

  test 'fails gracefully when user tries to find non existant photo' do
    visit '/an-album/photos/abc'
    assert_redirected_to album_url(Album.find_by_permalink('an-album')) # ugh
  end

  def visit(path) # ???
    get path
  end
end