steps_for(:webrat) do
  When "the user clicks on '$link'" do |link|
    click_link link
  end

  When "the user fills in $field with '$value'" do |field, value|
    fill_in field, :with => value
  end

  When "the user selects $field as '$option'" do |field, option|
    select option, :from => field
  end

  When "the user checks $checkbox" do |checkbox|
    check checkbox
  end

  When "the user unchecks '$checkbox'" do |checkbox|
    uncheck checkbox
  end

  When "the user clicks the '$button' button" do |button|
    click_button button
  end
end
