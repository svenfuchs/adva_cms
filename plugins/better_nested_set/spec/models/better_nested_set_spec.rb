require File.dirname(__FILE__) + '/../spec_helper'

class Node < ActiveRecord::Base
  unless table_exists?
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Schema.define(:version => 1) do
      create_table "nodes", :force => true do |t|
        t.string  :name
        t.integer :lft
        t.integer :rgt
        t.integer :parent_id
      end
    end
  end  
  acts_as_nested_set
end

describe 'BetterNestedSet' do
  fixtures :nodes
  before :each do 
    @root, @node_2, @node_3, @node_4 = Node.find [1, 2, 3, 4]
  end 
  
  describe "structure " do  
    it "#root should return the root node" do
      Node.root.name.should == 'root'
    end
      
    it "#root? should return true when called on the root node" do
      @root.root?.should be_true
    end
      
    it "#root? should return false when called on a child node" do
      @node_2.root?.should be_false
    end
      
    it "#child? should return false when called on the root node" do
      @root.child?.should be_false
    end
      
    it "#child? should return true when called on a child node" do
      @node_2.child?.should be_true
    end
      
    it "#parent should return a child's parent" do
      @node_2.parent.name.should == 'root'
    end
      
    it "#anchestors should return an array with a child's ancestors (starting with root)" do
      @node_4.ancestors.should == [@root, @node_3]
    end
      
    it "#self_and_ancestors should return an array with a child's ancestors including itself (starting with root)" do
      @node_4.self_and_ancestors.should == [@root, @node_3, @node_4]
    end
      
    it "#siblings should return an array with a child nodes siblings (except itself)" do
      @node_2.siblings.should == [@node_3]
    end
      
    it "#self_and_siblings should return an array with a child nodes siblings including itself" do
      @node_2.self_and_siblings.should == [@node_2, @node_3]
    end
    
    it "#left should return the next sibling on the left side of the node if there is one" do
      @node_3.left.should == @node_2
    end
    
    it "#left should return nil if there is no next sibling on the left side of the node" do
      @node_2.left.should be_nil
    end
    
    it "#right should return the next sibling on the right side of the node if there is one" do
      @node_2.right.should == @node_3
    end
    
    it "#right should return nil if there is no next sibling on the right side of the node" do
      @node_3.right.should be_nil
    end
      
    it "#children should return a node's immediate children" do
      @root.children.should == [@node_2, @node_3]
    end
      
    it "#all_children should return all of its nested children" do
      @root.all_children.should == [@node_2, @node_3, @node_4]
    end
      
    it "#full_set should return a set of itself and all of its nested children" do
      @root.full_set.should == [@root, @node_2, @node_3, @node_4]
    end
      
    it "#level should return node's level in the tree (starting with 0 for root)" do
      [@root, @node_2, @node_3, @node_4].map(&:level).should == [0, 1, 1, 2]
    end
      
    it "#children_count should return the number of nested child nodes" do
      [@root, @node_3, @node_4].map(&:children_count).should == [3, 1, 0]
    end
      
    it "should compare nodes by their lft columns" do
      [@root, @node_2, @node_4].collect{|node| @node_2 <=> node }.should == [1, 0, -1]
    end
  end
  
  describe "moving nodes around" do  
    it "#move_to_left_of should move a node to the left of another node" do
      @node_4.move_to_left_of @node_2
      @node_4.lft.should == 2
    end
  
    it "#move_to_left_of should change parent_id if necessary" do
      @node_2.move_to_left_of @node_4
      @node_2.parent.should == @node_3
    end
  
    it "#move_to_right_of should move a node to the right of another node" do
      @node_2.move_to_right_of @node_3
      @node_2.rgt.should == 7
    end
  
    it "#move_to_right_of should change parent_id if necessary" do
      @node_2.move_to_right_of @node_4
      @node_2.parent.should == @node_3
    end
  
    it "#move_to_child_of should move a node to the children collection of a parent node" do
      @node_4.move_to_child_of @root
      @node_4.parent.should == @root
    end
  
    it "#move_to_child_of should move a node to the leftmost position in the new parents children collection" do
      @node_4.move_to_child_of @root
      @node_4.lft.should == 2
    end
  end
  
  it "#before_create should set lft and rgt to the end of the tree" do
    node = Node.create :name => 'new'
    [node.lft, node.rgt].should == [9, 10]
  end
  
  it "should raise an error when directly assigning to lft" do
    lambda{ @root.lft = 2 }.should raise_error(ActiveRecord::ActiveRecordError)
  end
  
  it "should raise an error when directly assigning to rgt" do
    lambda{ @root.rgt = 2 }.should raise_error(ActiveRecord::ActiveRecordError)
  end
  
  it "should raise an error when directly assigning to parent_id" do
    lambda{ @root.parent_id = 2 }.should raise_error(ActiveRecord::ActiveRecordError)
  end
  
  describe "#update_attributes!" do
    it "with parent_id given should move the node to a children collection of that parent node" do
      @node_2.update_attributes! 'parent_id' => 3
      @node_2.parent.should == @node_3
    end
  
    it "with left_id given should move the node to the right of the node with that id" do
      @node_2.update_attributes! 'left_id' => @node_3.id
      @node_2.rgt.should == 7
    end
  
    it "with a blank left_id given should move the node to the left of the leftmost sibling with the given parent_id" do
      @node_4.update_attributes! 'left_id' => '', 'parent_id' => @root.id
      @node_4.lft.should == 2
    end

    it "with right_id given should move the node to the left of the node with that id" do
      @node_4.update_attributes! 'right_id' => @node_2.id
      @node_4.lft.should == 2
    end
  
    it "with a blank right_id given should move the node to the right of the rightmost sibling with the given parent_id" do
      @node_2.update_attributes! 'right_id' => '', 'parent_id' => @root.id
      @node_2.rgt.should == 7
    end 
  end
end