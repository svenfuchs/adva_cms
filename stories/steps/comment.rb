factories :articles

steps_for :comment do
  Given "a comment" do
    @comment = create_comment
  end
  
  Given "no comments exist" do
    Comment.delete_all
  end
  
  Given "the user is the anonymous author of the comment" do
    raise "this step expects @comment to be set" unless @comment
    raise "this step expects @anonymous to be set" unless @anonymous
    @comment.author = @anonymous
    @comment.save!
  end
  
  Then "a comment exists" do
    Comment.count.should == 1
  end
  
  Then "the comment is updated" do
    comment = controller.instance_variable_get :@comment
    comment.body.should == 'the updated comment body'
    comment.changed?.should be_false
  end
  
end