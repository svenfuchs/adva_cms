factories :articles

steps_for :article do
  Given "a published article" do
    create_published_article
  end
  
  Given "a published article that has $options" do |options|
    create_published_article options
  end
end