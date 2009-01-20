require File.dirname(__FILE__) + '/../spec_helper'

describe BlogCell do
  it "renders" do
    controller = mock('controller')
    cell = BlogCell.new(controller, nil)
    cell.render_state(:recent_articles).should =~ /recent \d* posts/i
  end
end