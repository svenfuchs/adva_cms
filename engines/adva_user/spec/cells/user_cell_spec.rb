require File.dirname(__FILE__) + '/../spec_helper'

describe UserCell do
  it "renders" do
    controller = mock('controller', :perform_caching => false)
    cell = UserCell.new(controller, nil)
    cell.render_state(:recent).should =~ /recent users/i
  end
end