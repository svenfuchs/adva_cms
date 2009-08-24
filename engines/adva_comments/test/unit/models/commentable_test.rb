require File.dirname(__FILE__) + '/../../test_helper'

class CommentableModelTest < ActiveSupport::TestCase
  def setup
    super
    @commentable = Content.new
  end

  test "has many comments" do
    @commentable.should have_many(:comments)
  end

  test "has many approved_comments" do
    @commentable.should have_many(:approved_comments)
  end

  test "has many unapproved_comments" do
    @commentable.should have_many(:unapproved_comments)
  end

  # FIXME how to specify this?
  # test 'comments.by_author is a shortcut to find_all_by_author_id_and_author_type' do
  #   mock(@commentable.comments).find_all_by_author_id_and_author_type
  #   @commentable.comments.by_author(User.new)
  # end

  # FIXME
  # test '#approved_comments_count returns the number of the approved comments'
  # TODO and it really should be implemented as a Counter ...
end