class Test::Unit::TestCase
  share :a_forum_with_boards do
    before do
      @section        = Forum.find_by_permalink 'a-forum-with-boards'
      @site           = @section.site
      @board          = @section.boards.find_by_title 'a board'
      @another_board  = @section.boards.find_by_title 'another board'
      set_request_host!
    end
  end
  
  share :a_forum_without_board do
    before do
      @section  = Forum.find_by_permalink 'a-forum-without-board'
      @site     = @section.site
      set_request_host!
    end
  end
end