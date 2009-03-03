module With
  class Context
    def it_raises(exception = nil)
      before { @_expected_exception = exception }
    end
  end
end