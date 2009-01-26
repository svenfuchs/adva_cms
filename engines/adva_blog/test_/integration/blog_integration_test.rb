require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))
# A blog with two category and with a published and an unpublished article. 
# The published article has an approved comment.
#
#   go to blog index page
#   assert blog/index
#   assert published article is displayed
#   assert unpublished article is not displayed
#
#   go to blog category index page
#   assert blog/index
#   assert published article is displayed
#   assert unpublished article is not displayed
#
#   go to another blog category index page
#   assert page is empty
#
#   go to blog tag index page
#   assert blog/index
#   assert published article is displayed
#   assert unpublished article is not displayed
#
#   go to another blog tag index page
#   assert page is empty
#
#   go to the blog's year archive page
#   assert blog/index
#   assert published article is displayed
#
#   go to the blog's previous year archive page
#   assert page is empty
#
#   go to the blog's month archive page
#   assert blog/index
#   assert published article is displayed
#
#   go to the blog's previous month archive page
#   assert page is empty
#
#   go to published blog article show page
#   assert blog/show
#   assert article is displayed
#   assert comment is displayed
#   assert page is cached
#
#   go to the unpublished blog article show page (not logged in)
#   assert 404
#
#   go to the unpublished blog article show page (logged in w/ write access)
#   assert blog/show
#   assert page is not cached
#
#   go to the published blog article show page (not logged in)
#   fill in and submit the comment form
#   assert comment/show
#
#   go to the published blog article show page (logged in)
#   fill in and submit the comment form
#   assert comment/show
#
#
#