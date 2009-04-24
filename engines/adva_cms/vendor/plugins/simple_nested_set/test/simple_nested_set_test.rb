require File.dirname(__FILE__) + '/test_helper'

class BetterNestedSetTest < ActiveSupport::TestCase
  fixtures :nodes
  
  # STRUCTURE
  
  test "Class.root returns the root node" do
    assert_equal 'root', FooNode.root(:foo_id => @root.foo_id).name
  end
  
  test "Class.roots returns the root nodes" do
    assert_equal ['root'], FooNode.roots(:foo_id => @root.foo_id).map(&:name)
  end
  
  test "#root returns self for root" do
    assert_equal @root, @root.root
  end
  
  test "#root returns the root for a non-root" do
    assert_equal @root, @node_4.root
  end
  
  test "#root? should return true when called on the root node" do
    assert @root.root?
  end
  
  test "#root? should return false when called on a child node" do
    assert !@node_2.root?
  end
  
  test "#child? should return false when called on the root node" do
    assert !@root.child?
  end
  
  test "#child? should return true when called on a child node" do
    assert @node_2.child?
  end
  
  test "#parent should return a child's parent" do
    assert_equal 'root', @node_2.parent.name
  end
  
  test "#anchestors should return an array with a child's ancestors (starting with root)" do
    assert_equal [@root, @node_3], @node_4.ancestors
  end
  
  test "#self_and_ancestors should return an array with a child's ancestors including itself (starting with root)" do
    assert_equal [@root, @node_3, @node_4], @node_4.self_and_ancestors
  end
  
  test "#siblings should return an array with a child nodes siblings (except itself)" do
    assert_equal [@node_3], @node_2.siblings
  end
  
  test "#self_and_siblings should return an array with a child nodes siblings including itself" do
    assert_equal [@node_2, @node_3], @node_2.self_and_siblings
  end
  
  test "#left should return the next sibling on the left side of the node if there is one" do
    assert_equal @node_2, @node_3.left
  end
  
  test "#left should return nil if there is no next sibling on the left side of the node" do
    assert @node_2.left.nil?
  end
  
  test "#right should return the next sibling on the right side of the node if there is one" do
    assert_equal @node_3, @node_2.right
  end
  
  test "#right should return nil if there is no next sibling on the right side of the node" do
    assert @node_3.right.nil?
  end
  
  test "#self_and_children should return a node and its immediate children" do
    assert_equal [@root, @node_2, @node_3], @root.self_and_children
  end
  
  test "#children returns a node's immediate children" do
    assert_equal [@node_2, @node_3], @root.children
  end
  
  test "#children returns an empty array for a leaf" do
    assert_equal [], @node_4.children
  end
  
  test "#children_count should return the number of nested child nodes" do
    assert_equal [3, 1, 0], [@root, @node_3, @node_4].map(&:children_count)
  end
  
  test "#descendants should return all of its nested children" do
    assert_equal [@node_2, @node_3, @node_4], @root.descendants
  end
  
  test "#descendants returns an empty array for a leaf" do
    assert_equal [], @node_4.descendants
  end
  
  test "#self_and_descendants should return a set of itself and all of its nested children" do
    assert_equal [@root, @node_2, @node_3, @node_4], @root.self_and_descendants
  end
  
  test "#level should return node's level in the tree (starting with 0 for root)" do
    assert_equal [0, 1, 1, 2], [@root, @node_2, @node_3, @node_4].map(&:level)
  end
  
  test "compares nodes by their lft columns" do
    assert_equal [1, 0, -1], [@root, @node_2, @node_4].collect{|node| @node_2 <=> node }
  end
  
  test "moving a node to itself raises an exception" do
    assert_raises(ActiveRecord::ActiveRecordError) { @node_2.move_to_left_of @node_2 }
  end
  
  test "moving a node to a different scope raises an exception" do
    assert_raises(ActiveRecord::ActiveRecordError) { @unrelated_root.move_to_child_of @node_2 }
  end
  
  test "moving a node to a target that is part of the moved branch raises an exception" do
    assert_raises(ActiveRecord::ActiveRecordError) { @node_3.move_to_child_of @node_4 }
  end
  
  # CREATION
  
  test "#before_create should set lft and rgt to the end of the tree" do
    node = FooNode.create! :name => 'new', :foo_id => @root.foo_id
    assert_equal [9, 10], [node.lft, node.rgt]
  end
  
  # test "should raise an error when directly assigning to lft" do
  #   assert_raises(ActiveRecord::ActiveRecordError) { @root.lft = 2 }
  # end
  # 
  # test "should raise an error when directly assigning to rgt" do
  #   assert_raises(ActiveRecord::ActiveRecordError) { @root.rgt = 2 }
  # end
  # 
  # test "should raise an error when directly assigning to parent_id" do
  #   assert_raises(ActiveRecord::ActiveRecordError) { @root.parent_id = 2 }
  # end
  
  # DELETION
  
  test "#before_destroy destroys all children" do
    @node_3.destroy
    assert_raises(ActiveRecord::RecordNotFound) { @node_4.reload }
  end
  
  test "#before_destroy closes the gaps" do
    @node_2.destroy
    assert_equal [[1, 6], [2, 5], [3, 4]], [@root, @node_3, @node_4].map { |node| [node.reload.lft, node.rgt] }
  end
  
  # MOVE
  
  # FIXME really should test #move_by_attributes
  
  test "#move_to_left_of move a node to the left of the target node" do
    @node_4.move_to_left_of @node_2
    assert_equal @node_2, @node_4.right
  end
  
  test "#move_to_left_of should change parent_id if necessary" do
    @node_2.move_to_left_of @node_4
    assert_equal @node_3, @node_2.parent
  end
  
  test "#move_to_right_of should move a node to the right of the target node" do
    @node_2.move_to_right_of @node_3
    assert_equal @node_3, @node_2.left
  end
  
  test "#move_to_right_of should change parent_id if necessary" do
    @node_2.move_to_right_of @node_4
    assert_equal @node_3, @node_2.parent
  end
  
  test "#move_to_child_of should move a node to the children collection of a parent node" do
    @node_4.move_to_child_of @root
    assert_equal @root, @node_4.parent
  end
  
  test "#move_to_child_of should move a node to the rightmost position in the new parents children collection" do
    @node_4.move_to_child_of @root
    assert_equal @node_3, @node_4.left
  end
  
  test "#move_to will only move nodes included in the nested_set's scope" do
    # FIXME
  end
  
  # update_attributes!
  test "with parent_id given should move the node to a children collection of that parent node" do
    @node_2.update_attributes! 'parent_id' => @node_3.id
    assert_equal @node_3, @node_2.parent
  end
  
  test "with left_id given should move the node to the right of the node with that id" do
    @node_2.update_attributes! 'left_id' => @node_3.id
    assert_equal @node_3, @node_2.left
  end
  
  test "with a blank left_id given should move the node to the left of the leftmost sibling with the given parent_id" do
    @node_4.update_attributes! 'left_id' => '', 'parent_id' => @root.id
    assert_equal @node_2, @node_4.right
  end
  
  test "with right_id given should move the node to the left of the node with that id" do
    @node_4.update_attributes! 'right_id' => @node_2.id
    assert_equal @node_2, @node_4.right
  end
  
  test "with a blank right_id given should move the node to the right of the rightmost sibling with the given parent_id" do
    @node_2.update_attributes! 'right_id' => '', 'parent_id' => @root.id
    assert_equal @node_3, @node_2.left
  end
end