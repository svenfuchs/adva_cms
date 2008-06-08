require File.dirname(__FILE__) + '/../spec_helper'

describe BaseHelper do
  describe '#cached_page_date' do
    it 'returns a variant of time_ago_in_words if the cached page was updated no more than 4 hours ago'
    it "returns a formatted date preceeded with 'Today' if the cached page was updated earlier today"
    it "returns a formatted date if the cached page was updated before today"
  end
end