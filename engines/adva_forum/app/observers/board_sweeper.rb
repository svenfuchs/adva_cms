class BoardSweeper < CacheReferences::Sweeper
  observe Board
  
  def after_create(board)
    expire_cached_pages_by_section(board.section)
  end

  def before_save(board)
    expire_cached_pages_by_reference(board)
  end

  alias after_destroy before_save
end