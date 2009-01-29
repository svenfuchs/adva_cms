require File.dirname(__FILE__) + '/../spec_helper'

describe AlbumCell do
  it "renders" do
    site = mock('site', :id => 1)
    section = mock('section', :id => 1, :track_method_calls => nil) # TODO: use real object?
    controller = mock('controller', :perform_caching => false, :site => site, :section => section)
    cell = AlbumCell.new(controller, nil)
    cell.render_state(:single).should =~ /album/i
  end
end