# require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper' ))
#
# class TopicsTest < ActionController::IntegrationTest
#   def setup
#     super
#     @site = use_site! 'site with forum'
#   end
#
#   # without boards
#
#   test 'an admin visits the new topic form' do
#     login_as_admin
#     visit_boardless_forum_backend
#     visit_new_topic_form
#   end
#
#   test 'an admin creates a new topic' do
#     login_as_admin
#     visit_boardless_forum_backend
#     visit_new_topic_form
#     fill_in_and_submit_new_topic_form
#   end
#
#   # with boards
#
#   test 'an admin visits the new topic form (with boards)' do
#     login_as_admin
#     visit_forum_backend
#     visit_new_topic_form
#   end
#
#   test 'an admin creates a new topic (with boards)' do
#     login_as_admin
#     visit_forum_backend
#     visit_new_topic_form
#     fill_in_and_submit_new_topic_form
#   end
#
#   def visit_forum_backend
#     @forum = Forum.find_by_permalink('a-forum-with-boards')
#     @board = @forum.boards.find_by_title('a board')
#
#     get admin_boards_path(@site, @forum)
#     assert_template 'admin/boards/index'
#   end
#
#   def visit_boardless_forum_backend
#     @forum = Forum.find_by_permalink('a-forum-without-boards')
#
#     get admin_boards_path(@site, @forum)
#     assert_template 'admin/boards/index'
#   end
#
#   def visit_new_topic_form
#     click_link 'Create a new Topic'
#     assert_template 'topics/new'
#   end
#
#   def fill_in_and_submit_new_topic_form
#     topic_count = @forum.topics.size
#
#     fill_in :title, :with => 'new topic title'
#     fill_in :body,  :with => 'new topic body'
#     click_button 'Post Topic'
#
#     assert_template 'topics/show'
#     assert @forum.topics.size == topic_count + 1
#   end
# end