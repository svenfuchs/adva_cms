factories :sections, :articles

steps_for :article do
  Given 'the article does not allow commenting' do
    @article.update_attributes! :comment_age => -1
  end
  
  Given "the article has no comments" do
    @article.comments.clear
  end
  
  Given "the article has a comment" do
    @comment = create_comment :commentable => @article
  end
  
  Given "the article has an approved comment" do
    Given "the article has a comment"
    @comment.update_attributes! :approved => true
  end
  
  Given "the article has an unapproved comment" do
    Given "the article has a comment"
  end
  
  Then "the article has an unapproved comment" do
    @article.unapproved_comments.count.should == 1
    @comment = @article.unapproved_comments.first
  end
end