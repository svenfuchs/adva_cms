factories :articles

steps_for :tag do
  Given "an unrelated tag" do
    @another_tag = Tag.find_by_name('baz') || create_tag(:name => 'baz')
  end
end
