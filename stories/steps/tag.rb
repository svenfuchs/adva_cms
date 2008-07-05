factories :articles

steps_for :tag do
  Given "an unrelated tag" do
    @another_tag = create_tag :name => 'baz'
  end
end