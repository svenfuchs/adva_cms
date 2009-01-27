require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

class BlogIntegrationTest < ActionController::IntegrationTest
  def setup
    super
  end

end

# # An empty site.
# 
# go to admin/section/new page and create a new blog
# assert admin/articles/index
#
# go to admin/section/edit page
# fill in and submit the section form
# assert admin/section/edit
#
# click on 'delete'
# assert section deleted