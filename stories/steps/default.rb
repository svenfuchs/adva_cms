steps_for :default do
  When "the user GETs $path" do |path|
    get '/'
  end
  
  Then "the page shows $text" do |text|
    text = /#{text}/i unless text.is_a? Regexp
    response.should have_text(text)
  end  
  
  Then "the page does not show $text" do |text|
    text = /#{text}/i unless text.is_a? Regexp
    response.should_not have_text(/#{text}/i)
  end
end