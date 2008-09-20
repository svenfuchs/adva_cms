scenario :blog_comments do
  raise 'scenario blog_comments requires @article to be defined' unless @article

  @comment = stub_comment
  @comments = stub_comments
  @comment.stub!(:commentable).and_return @article
  @comment.stub!(:commentable=)

  Comment.stub!(:find).and_return @comment
end

