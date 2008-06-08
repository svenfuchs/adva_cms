require File.dirname(__FILE__) + '/../spec_helper'

describe BaseHelper do
  it '#link_to_section_main_action should probably be solved differently'
  
  describe '#funky_form_for' do
    it 'needs a better name'
    it 'splits off the form head tag from the generated form'
    it 'captures form head tag to content_for :form'
  end
  
  describe '#pluralize_str' do
    it 'returns the singular of the passed string if count equals 1'
    it 'returns the passed plural of the passed string if count equals 1 and a plural has been passed'
    it "returns the passed singluar's pluralization if count equals 1 and a plural has been passed"
    it 'interpolates the count to the returned result'
  end
  
  describe 'date helpers' do
    it '#todays_short_date returns a short formatted version of Time.zone.now'
    it '#yesterdays_short_date returns a short formatted version of Time.zone.now.yesterday'
  end
  
  it '#filter_options returns a nested array containing the installed column filters'
  
end