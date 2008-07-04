steps_for(:webrat) do
  When "the user clicks on '$link'" do |link|
    clicks_link link
  end

  When "the user fills in $field with '$value'" do |field, value|
    fills_in field, :with => value
  end  

  When "the user selects $field as '$option'" do |field, option|
    selects option, :from => field
  end
  
  When "the user checks $checkbox" do |checkbox|
    checks checkbox
  end
  
  When "the user clicks the $button button" do |button|
    clicks_button button
  end 
end