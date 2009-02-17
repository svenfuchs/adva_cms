# FIXME use registry instead?

# require File.dirname(__FILE__) + '/../spec_helper'
#
# describe Adva::Config do
#   describe "number_of_outgoing_mails_per_process" do
#     it "should return default value" do
#       Adva::Config.number_of_outgoing_mails_per_process = nil
#       Adva::Config.number_of_outgoing_mails_per_process.should == 150
#     end
#   end
#
#   describe "email_header" do
#     it "should return default values" do
#       Adva::Config.email_header.should == {"X-Mailer" => "Adva-CMS"}
#     end
#   end
#
#   describe "email_header=" do
#     it "should override default values of class variable" do
#       Adva::Config.email_header = {"X-Mailer" => "Example"}
#       Adva::Config.email_header.should == {"X-Mailer" => "Example"}
#     end
#   end
# end
