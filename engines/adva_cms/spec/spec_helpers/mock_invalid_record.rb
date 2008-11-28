module MockInvalidRecord
  def mock_invalid_record(name = 'invalid_record')
    invalid_record, errors = mock(name), mock('errors')
    invalid_record.stub!(:errors).and_return(errors)
    errors.stub!(:full_messages).and_return(['errors'])
    invalid_record
  end
end
