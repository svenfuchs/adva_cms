# apparently on rails 2.3 transactions are already started and rolled back?

class Test::Unit::TestCase
  def start_db_transaction!
    # ActiveRecord::Base.connection.increment_open_transactions
    # ActiveRecord::Base.connection.begin_db_transaction
  rescue SQLite3::SQLException => e
  end

  def rollback_db_transaction!
    # ActiveRecord::Base.connection.rollback_db_transaction
    # ActiveRecord::Base.connection.decrement_open_transactions
  rescue SQLite3::SQLException => e
  end
end