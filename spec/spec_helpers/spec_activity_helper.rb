module SpecActivityHelper  
  # TODO move to a matcher (maybe analog to the raise_error matcher)
  def expect_activity_new_with(expected)
    activity = Activity.new expected
    activity.stub!(:create_or_update).and_return true
    Activity.should_receive(:new){|actual|
      actual.slice(*expected.keys).should == expected
      activity
    }
  end
    
  # def edited(comment)
  #   returning comment do 
  #     comment.stub!(:new_record?).and_return(false)
  #     comment.stub!(:body_changed?).and_return(true)
  #   end
  # end
  #   
  # def revised(object)
  #   returning object do 
  #     object.stub!(:new_record?).and_return(false)
  #     object.stub!(:save_version?).and_return(true)
  #   end
  # end
  #   
  # def published(object)
  #   returning object do 
  #     object.stub!(:new_record?).and_return(false)
  #     object.stub!(:published?).and_return(true)
  #     object.stub!(:published_at_changed?).and_return(true)
  #   end
  # end
  #   
  # def unpublished(object)
  #   returning object do 
  #     object.stub!(:new_record?).and_return(false)
  #     object.stub!(:draft?).and_return(true)
  #     object.stub!(:published_at_changed?).and_return(true)
  #   end
  # end
  #   
  # def approved(comment)
  #   returning comment do 
  #     comment.stub!(:new_record?).and_return(false)
  #     comment.stub!(:approved?).and_return(true)
  #     comment.stub!(:approved_changed?).and_return(true)
  #   end
  # end
  #   
  # def unapproved(comment)
  #   returning comment do 
  #     comment.stub!(:new_record?).and_return(false)
  #     comment.stub!(:draft?).and_return(true)
  #     comment.stub!(:approved_changed?).and_return(true)
  #   end
  # end
  #   
  # def destroyed(object)
  #   returning object do 
  #     object.stub!(:new_record?).and_return(false)
  #     object.stub!(:frozen?).and_return(true)
  #   end
  # end
end