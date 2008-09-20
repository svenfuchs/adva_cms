factories :articles

steps_for :category do
  Given "an unrelated category" do
    @another_category = create_category :title => 'an unrelated category'
  end
end
