factories :sections

steps_for :section do
  Given "a section" do
    @section = create_section
  end
end