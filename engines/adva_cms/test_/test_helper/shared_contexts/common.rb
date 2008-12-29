class Test::Unit::TestCase
  share :save_revision_param do
    before { @params.merge! :save_revision => '1' }
  end

  share :no_save_revision_param do
    before { @params = @params.except(:save_revision) }
  end
end