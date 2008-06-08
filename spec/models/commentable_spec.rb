require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/spec_comment_helper'

describe 'A model acting as a commentable' do
  before :each do
    @commentable = Commentable.new
  end
  
  it "has many comments" do
    @commentable.should have_many(:comments)
  end
  
  it "has many approved_comments" do
    @commentable.should have_many(:approved_comments)
  end
  
  it "has many unapproved_comments" do
    @commentable.should have_many(:unapproved_comments)
  end
  
  describe 'the comments association' do
    it '#by_author is a shortcut to find_all_by_author_id_and_author_type' do
      @commentable.comments.should_receive(:find_all_by_author_id_and_author_type)
      @commentable.comments.by_author(User.new)
    end
    
    it 'last_one is a shortcut to find :last' do
      @commentable.comments.should_receive(:find).with(:last)
      @commentable.comments.last_one
    end
  end
  
  it '#approved_comments_count returns the number of the approved comments' 
  # TODO and it really should be implemented as a Counter ...
end