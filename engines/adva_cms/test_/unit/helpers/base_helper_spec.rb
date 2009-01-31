# FIXME ... integrate with base_helper_test.rb

# require File.dirname(__FILE__) + '/../spec_helper'
# 
# describe BaseHelper do
#   describe "#datetime_with_microformat" do
#     before :each do
#       @utc_time = Time.utc(2008, 10, 9, 12, 0, 0)
#       Time.zone = 'America/New_York'
#       @local_time = Time.zone.local(2008, 10, 9, 12, 0, 0) # is 16:00Z or 18:00 CEST
#       Time.zone = :utc
#     end
# 
#     it "displays the passed object when passed a non-Date/Time object" do
#       helper.datetime_with_microformat(nil).should be_nil
#       helper.datetime_with_microformat(1).should == 1
#       helper.datetime_with_microformat('1').should == '1'
#     end
# 
#     it "displays a UTC time in UTC" do    
#       helper.datetime_with_microformat(@utc_time).should == '<abbr class="datetime" title="2008-10-09T12:00:00Z">October 09, 2008 @ 12:00 PM</abbr>'
#     end
# 
#     it "displays a UTC time in New York" do
#       Time.zone = "America/New_York"
#       helper.datetime_with_microformat(@utc_time).should == '<abbr class="datetime" title="2008-10-09T12:00:00Z">October 09, 2008 @ 08:00 AM</abbr>'
#     end
# 
#     it "displays a New York time in Vienna" do
#       Time.zone = "Europe/Vienna"
#       helper.datetime_with_microformat(@local_time).should == '<abbr class="datetime" title="2008-10-09T16:00:00Z">October 09, 2008 @ 06:00 PM</abbr>'
#     end
# 
#     it "displays a non-UTC time and converts it to UTC" do
#       helper.datetime_with_microformat(@local_time).should == '<abbr class="datetime" title="2008-10-09T16:00:00Z">October 09, 2008 @ 04:00 PM</abbr>'
#     end
# 
#     it "displays a UTC time with a given date format" do
#       helper.datetime_with_microformat(@utc_time, :format => :plain).should == '<abbr class="datetime" title="2008-10-09T12:00:00Z">October 09 12:00 PM</abbr>'
#     end
# 
#     it "displays a non-UTC time with a given date format and converts it to UTC" do
#       helper.datetime_with_microformat(@local_time, :format => :plain).should == '<abbr class="datetime" title="2008-10-09T16:00:00Z">October 09 04:00 PM</abbr>'
#     end
# 
#     it "displays a UTC time with a given custom date format" do
#       helper.datetime_with_microformat(@utc_time, :format => '%Y/%m/%d').should == '<abbr class="datetime" title="2008-10-09T12:00:00Z">2008/10/09</abbr>'
#     end
# 
#     it "displays a non-UTC time with a given custom date format and converts it to UTC" do
#       helper.datetime_with_microformat(@local_time, :format => '%Y/%m/%d').should == '<abbr class="datetime" title="2008-10-09T16:00:00Z">2008/10/09</abbr>'
#     end
#   end
# end
