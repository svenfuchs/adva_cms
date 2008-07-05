factories :articles

steps_for :article do
  Given "an article" do
    @article = create_article
  end
  
  Given "an article that has $options" do |options|
    @article = create_article options
  end
  
  Given "the article is published" do
    @article.update_attributes! :published_at => '2008-01-01 12:00:00'
  end
  
  Given "the article is not published" do
    @article.update_attributes! :published_at => nil
  end
  
  Given "the article does not allow commenting" do
    @article.update_attributes! :comment_age => -1
  end
  
  Given "a published article" do
    Given "an article"
    Given "the article is published"
  end
  
  Given "an unrelated category" do
    @another_category = create_category :title => 'an unrelated category'
  end
  
  Given "an unrelated tag" do
    @another_tag = create_tag :name => 'baz'
  end
  
  Given "the article has a comment" do
    @approved_comment = create_comment :commentable => @article
  end
  
  Given "the comment is approved" do
    @approved_comment.update_attributes! :approved => true
  end
end
