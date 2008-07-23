steps_for :forum do
  Given 'a forum' do
    @forum ||= begin
      Given 'a site'
      create_forum :site => @site
    end
  end

  Given "a forum that allows anonymous users to post comments" do
    Given "a forum"
    @forum.update_attributes! 'permissions' => {'comment' => {'show' => 'anonymous', 'create' => 'anonymous'}}
  end
  
  Given "the forum has no boards" do
    Board.delete_all
  end
  
  When "the user goes to the forum page" do
    get forum_path(@forum)
  end
  
  Then "the page shows an empty list of topics" do
    response.should have_tag('#topics.empty')
  end
end