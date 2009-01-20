require File.dirname(__FILE__) + '/../spec_helper'

describe AlbumCell do
  it "renders" do
    controller = mock('controller')
    cell = AlbumCell.new(controller, nil)
    cell.render_state(:single).should =~ /album/i
  end
end