require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class PhotosFrontendTest < ActionController::IntegrationTest
  def setup
    super
    @site   = use_site! 'site with pages'
    @album                  = Album.find_by_permalink('an-album')
    @unpublished_photo      = Photo.find_by_title('a photo')
    @photo                  = Photo.find_by_title('a published photo')
    @photo_with_tag         = Photo.find_by_title('a published photo with tag')
    @photo_with_set         = Photo.find_by_title('a published photo with set')
    @photo_with_set_and_tag = Photo.find_by_title('a published photo with set and tag')
    @set                    = Category.find_by_title('Summer')
    @tag                    = Tag.find_by_name('Forest')
  end

  test 'an anonymous user views the album' do
    visit_album
    assert_unpublished_photo_is_not_shown
    assert_displays_at_least_one_photo

    if default_theme?
      assert_displays_published_photo
      assert_displays_published_photo_with_set
      assert_displays_published_photo_with_tag
      assert_displays_published_photo_with_set_and_tag
    end
  end

  test 'an anonymous user views a set' do
    visit_album
    view_the_set
  
    assert_unpublished_photo_is_not_shown
    assert_published_photo_is_not_shown
    assert_published_photo_with_tag_is_not_shown
  
    assert_displays_published_photo_with_set
    assert_displays_published_photo_with_set_and_tag
  end
  
  test 'an anonymous user views a tag' do
    visit_album
    if default_theme?
      view_the_tag
  
      assert_unpublished_photo_is_not_shown
      assert_published_photo_is_not_shown
      assert_published_photo_with_set_is_not_shown
  
      assert_displays_published_photo_with_tag
      assert_displays_published_photo_with_set_and_tag
    end
  end
  
  test 'an anonymous user views an empty tag' do
    visit_album
    if default_theme?
      view_the_empty_tag
  
      assert_unpublished_photo_is_not_shown
      assert_published_photo_is_not_shown
      assert_published_photo_with_set_is_not_shown
      assert_published_photo_with_tag_is_not_shown
      assert_published_photo_with_set_and_tag_is_not_shown
    end
  end
  
  test 'an anonymous user views an empty set' do
    visit_album
    view_the_empty_set
  
    assert_unpublished_photo_is_not_shown
    assert_published_photo_is_not_shown
    assert_published_photo_with_set_is_not_shown
    assert_published_photo_with_tag_is_not_shown
    assert_published_photo_with_set_and_tag_is_not_shown
  end

  def visit_album
    get "/albums/#{@album.id}"
    assert_template 'albums/index'
  end

  def view_the_set
    click_link @set.title
    assert_template 'albums/index'
  end

  def view_the_tag
    click_link @tag.name
    assert_template 'albums/index'
  end

  def view_the_empty_tag
    get "/an-album/tags/Empty"
    assert_template 'albums/index'
  end

  def view_the_empty_set
    get "/an-album/sets/empty"
    assert_template 'albums/index'
  end

  def assert_displays_at_least_one_photo
    assert_select ".content img[src*=/photos/]"
  end

  def assert_displays_published_photo_with_set_and_tag
    assert_select "div#photo_#{@photo_with_set_and_tag.id}" do
      assert_select "a[href='#{controller.show_path(@photo_with_set_and_tag)}']"
    end
  end

  def assert_published_photo_with_set_and_tag_is_not_shown
    assert_select "div#photo_#{@photo_with_set_and_tag.id}", false
  end

  def assert_displays_published_photo_with_tag
    assert_select "div#photo_#{@photo_with_tag.id}" do
      assert_select "a[href='#{controller.show_path(@photo_with_tag)}']"
    end
  end

  def assert_published_photo_with_tag_is_not_shown
    assert_select "div#photo_#{@photo_with_tag.id}", false
  end

  def assert_displays_published_photo_with_set
    assert_select "div#photo_#{@photo_with_set.id}" do
      assert_select "a[href='#{controller.show_path(@photo_with_set)}']"
    end
  end

  def assert_published_photo_with_set_is_not_shown
    assert_select "div#photo_#{@photo_with_set.id}", false
  end

  def assert_displays_published_photo
    assert_select "div#photo_#{@photo.id}" do
      assert_select "a[href='#{controller.show_path(@photo)}']"
    end
  end

  def assert_published_photo_is_not_shown
    assert_select "div#photo_#{@photo.id}", false
  end

  def assert_unpublished_photo_is_not_shown
    assert_select "div#photo_#{@unpublished_photo.id}", false
  end
end