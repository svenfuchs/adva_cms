require File.dirname(__FILE__) + '/../spec_helper'

describe Anonymous do
  before :each do 
    @anonymous = Anonymous.new 
  end
  
  describe 'class extensions:' do
    it 'acts as authenticated user with single token authentication'
  end
  
  describe 'validations:' do
    it 'validates the presence of a name' do
      @anonymous.should validate_presence_of(:name)
    end
    
    it 'validates the presence of an email' do
      @anonymous.should validate_presence_of(:email)
    end
    
    it 'validates the length of the name (3-40 chars)' do
      @anonymous.should validate_length_of(:name, :within => 3..40)
    end
    
    it 'validates the format of the email' # do TODO
    #  @anonymous.should validate_format_of(:email) 
    # end
  end
  
  describe '#has_role?' do
    it 'turns the passed arg to a role if its a role name'
    it 'returns true when the role is Role::Anonymous'
    it 'returns false when the role is not Role::Anonymous'
  end
  
  it '#anonymous? returns true' do
    @anonymous.anonymous?.should be_true
  end
  
  it '#registered? returns false' do
    @anonymous.registered?.should be_false
  end
  
end