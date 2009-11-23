require File.expand_path(File.dirname(__FILE__) + '/../test_helper' )

module IntegrationTests
  class PhotoCommentsTest < ActionController::IntegrationTest
    def setup
      super
      @section = Album.first
      @photo   = @section.photos.find_by_title('a published photo')
      @site    = @section.site
      
      @section.update_attribute(:comment_age, 0) # Comments never expire
      use_site! @site
    end
  
    test "user comments a photo (lighthouse ticket #230)" do
      if Rails.plugin?(:adva_comments)
        login_as_user
        visit_album_index
        if default_theme?
          visit_photo
          post_comment
        end
      end
    end
    
    def visit_album_index
      visit album_path(@section)
      assert_template 'albums/index'
    end
    
    def visit_photo
      click_link @photo.title
      assert_template 'albums/show'
    end
    
    def post_comment
      comment_count = @photo.comments.size
      
      fill_in       :comment_body, :with => "Nice photo!"
      click_button  'Submit Comment'
      
      @photo.comments.reload
      assert_template 'comments/show'
      assert_equal comment_count + 1, @photo.comments.size
    end
  end
end