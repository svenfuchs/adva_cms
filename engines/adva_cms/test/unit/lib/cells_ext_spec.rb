# FIXME implement

# require File.dirname(__FILE__) + '/spec_helper'
# require 'cells_ext'
# 
# class TestCell < BaseCell
#   def exposed_state; nil; end;
#   def unexposed_state; nil; end;
# 
#   has_state :exposed_state
# end
# 
# describe Cell do
#   describe "class methods" do
#     describe ".all" do
#       it "responds to .all" do
#         Cell.should respond_to(:all)
#       end
# 
#       it "returns a collection of cells" do
#         Cell.all.should be_a_kind_of(Array)
#       end
# 
#       it "returns a collection that can be serialized to XML" do
#         Cell.all.should respond_to(:to_xml)
#       end
# 
#       it "returns a collection of BaseCell objects" do
#         Cell.all.each do |cell|
#           Object.subclasses_of(BaseCell).should include(cell)
#         end
#       end
#     end
# 
#     describe ".has_state" do
#       before(:each) do
#         TestCell.states = [:exposed_state]
#       end
# 
#       it "adds a new state if the state exists" do
#         #lambda { TestCell.has_state :unexposed_state }.should change(TestCell, :states) # TODO: somehow this doesn't work ...
#         TestCell.states.should_not include(:unexposed_state)
#         TestCell.has_state :unexposed_state
#         TestCell.states.should include(:unexposed_state)
#       end
# 
#       # TODO: should we somewhere exclude nonexistent states?
#       it "adds a new state even if the state doesn't exist" do
#         #lambda { TestCell.has_state :nonexistent_state }.should_not change(TestCell, :states) # TODO: somehow this doesn't work ...
#         TestCell.states.should_not include(:nonexistent_state)
#         TestCell.has_state :nonexistent_state
#         TestCell.states.should include(:nonexistent_state)
#       end
#     end
# 
#     describe ".states" do
#       it "responds to states" do
#         TestCell.should respond_to(:states)
#       end
# 
#       it "returns an array" do
#         TestCell.states.should be_a_kind_of(Array)
#       end
# 
#       # TODO: is it good to test this heavily for implementation?
#       it "returns the cell's exposed states" do
#         TestCell.states.should include(:exposed_state)
#       end
#     end
# 
#     describe ".to_xml" do
#       it "responds to to_xml" do
#         TestCell.should respond_to(:to_xml)
#       end
# 
#       it "translates the cell's name and its states' names and descriptions" do
#         I18n.should_receive(:translate).with(:'adva.cells.test.name', :default => 'Test')
# 
#         I18n.should_receive(:translate).with(:'adva.cells.test.states.exposed_state.name', :default => 'Exposed state')
#         I18n.should_receive(:translate).with(:'adva.cells.test.states.exposed_state.description', :default => '')
# 
#         I18n.should_receive(:translate).with(:'adva.cells.test.states.nonexistent_state.name', :default => 'Nonexistent state')
#         I18n.should_receive(:translate).with(:'adva.cells.test.states.nonexistent_state.description', :default => '')
# 
#         TestCell.to_xml
#       end
# 
#       # TODO: maybe test the output?
#       # it "...?" do
#       #   require 'rexml'
#       #
#       #   xml = REXML::Document.new(@cell.to_xml)
#       # end
#     end
#   end
# end