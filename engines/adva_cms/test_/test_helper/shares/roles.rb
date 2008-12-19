class Test::Unit::TestCase
  share :admin_may_edit_articles do
    before { @section.update_attributes! :permissions => { 'update article' => 'admin' } }
  end
end