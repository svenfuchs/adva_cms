Factory.define_scenario :board_with_topics do
  raise "@forum or @section and @user variables must be set" unless @user && @forum || @section
  @forum        = @forum || @section
  @board        = Factory :board, :section => @forum
  @topic        = Factory :topic, :section => @forum, :author => @user, :last_updated_at => 1.month.ago
  @recent_topic = Factory :topic, :section => @forum, :author => @user, :last_updated_at => Time.now
  @board.topics << @topic
  @board.topics << @recent_topic
end