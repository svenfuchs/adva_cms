class Test::Unit::TestCase
  share :valid_comment_params do
    before do
      @params = { :comment => { :commentable_id => @article.id, 
                                :commentable_type => 'Article', 
                                :body => 'the comment body' } }
    end
  end
  
  share :invalid_comment_params do
    before do
      @params = { :comment => { :commentable_id => @article.id, 
                                :commentable_type => 'Article', 
                                :body => nil } }
    end
  end

  share :an_approved_comment do
    before do 
      @comment = @section.approved_comments.first
    end
  end

  share :an_unapproved_comment do
    before do 
      @comment = @section.unapproved_comments.first
    end
  end
end