function log(line) {
  $('log').update($('log').innerHTML + "<p>" + line + "</p>")
}

var tests = {
  testfind: function() {
    if($("tree") != tree.find('tree').element) 
      log("find('tree') doesn't seem to find the root node");

    if($("node_1") != tree.find('node_1').element) 
      log("find('node_1') doesn't seem to find the correct node");
      
    if($("node_112") != tree.find('node_112').element) 
      log("find('node_112') doesn't seem to find the correct node");
  },
  testChildren: function() {
    if(tree.find('node_1').children.length != 3) 
      log('node 1 children.length != 3, but is: ' + tree.find('node_1').children.length);
  
    if(tree.find('node_11').children.length != 3) 
      log('node 11 children.length != 3, but is: ' + tree.find('node_11').children.length);
  
    if(tree.find('node_111').children.length != 0) 
      log('node 111 children.length != 0, but is: ' + tree.find('node_111').children.length);
  },
  testFirstChild: function() {
    if(tree.find('node_11').firstChild().element != $('node_111')) 
      log('firstChild() does not return 111');
      
    if(tree.find('node_111').firstChild() != null) 
      log('firstChild() does not return null');
  },
  testNextSibling: function() {
    if(tree.find('node_112').nextSibling().element != $('node_113')) 
      log('nextSibling() does not return 113');
      
    if(tree.find('node_113').nextSibling() != null) 
      log('nextSibling() does not return null');
  },
  testPreviousSibling: function() {
    if(tree.find('node_111').previousSibling() != null) 
      log('previousSibling() does not return null');
      
    if(tree.find('node_112').previousSibling().element != $('node_111')) 
      log('previousSibling() does not return 111');
  },
  testRemoveChild: function() {
    var node = tree.find('node_23');
    tree.find('node_2').removeChild(node);
    
    if(tree.find('node_23') != null) 
      log('removeChild("23") did not remove the node from the tree');
    
    if(node.element.parent != null) 
      log('after removeChild() node.element is still part of the DOM');
  },
  testInsertBeforeSibling: function() {
    var node = tree.find('node_22');
    var sibling = tree.find('node_13');
    var parent = tree.find('node_1');
  
    parent.insertBefore(node, sibling);
    
    if(parent.children.length != 4) 
      log('after insertBefore parent.children.length != 4, but is: ' + parent.children.length);
    
    if(node.parent != parent) 
      log('after insertBefore node.parent != parent, but has the id: ' + node.parent.element.id);
    
    if(node.parent.element.id != 'node_1') 
      log("after insertBefore node.parent.element.id != 'node_1', but is: " + node.parent.element.id);
    
    if(node.previousSibling() != tree.find('node_12')) 
      log("after insertBefore node.previousSibling() != tree.find('node_12'), instead it is: " + node.previousSibling().element.id);
    
    if(node.nextSibling() != tree.find('node_13')) 
      log("after insertBefore node.nextSibling() != tree.find('node_13'), instead it is: " + node.nextSibling().element.id);
      
    if(node.element.parentNode.parentNode != parent.element)
      log("after insertBefore node.element.parentNode.parentNode != parent.element, instead it is: " + node.element.parentNode.parentNode.id)
  
    if(node.element.previousSibling.previousSibling != tree.find('node_12').element)
      log("after insertBefore node.element.previousSibling.previousSibling != tree.find('node_12').element, instead it is: " + node.element.previousSibling.previousSibling.id)
  },
  testInsertBeforeNull: function() {
    var node = tree.find('node_21');
    var parent = tree.find('node_1');
  
    parent.insertBefore(node);
    
    if(parent.children.length != 5) 
      log('after insertBefore parent.children.length != 5, but is: ' + parent.children.length);
    
    if(node.parent != parent) 
      log('after insertBefore node.parent != parent, but has the id: ' + node.parent.element.id);
    
    if(node.parent.element.id != 'node_1') 
      log("after insertBefore node.parent.element.id != 'node_1', but is: " + node.parent.element.id);
    
    if(node.previousSibling() != tree.find('node_13')) 
      log("after insertBefore node.previousSibling() != tree.find('node_13'), instead it is: " + node.previousSibling().element.id);
    
    if(node.nextSibling() != null) 
      log("after insertBefore node.nextSibling() != null, instead it is: " + node.nextSibling().element.id);
      
    if(node.element.parentNode.parentNode != parent.element)
      log("after insertBefore node.element.parentNode.parentNode != parent.element, instead it is: " + node.element.parentNode.parentNode.id)
    
    if(node.element.previousSibling.previousSibling != tree.find('node_13').element)
      log("after insertBefore node.element.previousSibling.previousSibling != tree.find('node_13').element, instead it is: " + node.element.previousSibling.previousSibling.id)
  },
  testInsertBeforeFirstSibling: function() {
    var node = tree.find('node_21');
    var sibling = tree.find('node_11');
    var parent = tree.find('node_1');
  
    parent.insertBefore(node, sibling);
    
    if(parent.children.length != 5)
      log('after insertBefore parent.children.length != 5, but is: ' + parent.children.length);
    
    if(node.parent != parent) 
      log('after insertBefore node.parent != parent, but has the id: ' + node.parent.element.id);
    
    if(node.parent.element.id != 'node_1') 
      log("after insertBefore node.parent.element.id != 'node_1', but is: " + node.parent.element.id);
    
    if(node.previousSibling() != null) 
      log("after insertBefore node.previousSibling() != null, instead it is: " + node.previousSibling().element.id);
    
    if(node.nextSibling() != tree.find('node_11')) 
      log("after insertBefore node.nextSibling() != tree.find('node_11'), instead it is: " + node.nextSibling().element.id);
      
    if(node.element.parentNode.parentNode != parent.element)
      log("after insertBefore node.element.parentNode.parentNode != parent.element, instead it is: " + node.element.parentNode.parentNode.id)
  
    if(node.element.nextSibling != tree.find('node_11').element)
      log("after insertBefore node.element.nextSibling != tree.find('node_11').element, instead it is: " + node.element.nextSibling.id)
  },
  testInsertBeforeSelf: function() {
    var node = tree.find('node_13');
    var sibling = node;
    var parent = tree.find('node_1');
  
    parent.insertBefore(node, sibling);
    
    if(parent.children.length != 5)
      log('after insertBefore parent.children.length != 5, but is: ' + parent.children.length);
    
    if(node.parent != parent) 
      log('after insertBefore node.parent != parent, but has the id: ' + node.parent.element.id);
    
    if(node.parent.element.id != 'node_1') 
      log("after insertBefore node.parent.element.id != 'node_1', but is: " + node.parent.element.id);
    
    if(node.previousSibling() != tree.find('node_22')) 
      log("after insertBefore node.previousSibling() != tree.find('node_22'), instead it is: " + node.previousSibling().element.id);
    
    if(node.nextSibling() != null) 
      log("after insertBefore node.nextSibling() != null, instead it is: " + node.nextSibling().element.id);
      
    if(node.element.parentNode.parentNode != parent.element)
      log("after insertBefore node.element.parentNode.parentNode != parent.element, instead it is: " + node.element.parentNode.parentNode.id)
  
    if(node.element.previousSibling != tree.find('node_22').element)
      log("after insertBefore node.element.previousSibling != tree.find('node_22').element, instead it is: " + node.element.nextSibling.id)
  },
  testSelfInsertBeforeFirstSiblingTopLevel: function() {
    var node = tree.find('node_1');
    var sibling = tree.find('node_1');
    var parent = tree.root;

    parent.insertBefore(node, sibling);

    if(parent.children.length != 2)
      log('after insertBefore parent.children.length != 2, but is: ' + parent.children.length);
    
    if(node.parent != parent) 
      log('after insertBefore node.parent != parent, but has the id: ' + node.parent.element.id);
    
    if(node.parent.element.id != 'tree') 
      log("after insertBefore node.parent.element.id != 'tree', but is: " + node.parent.element.id);
    
    if(node.previousSibling() != null) 
      log("after insertBefore node.previousSibling() != null, instead it is: " + node.previousSibling().element.id);
    
    if(node.nextSibling() != tree.find('node_2')) 
      log("after insertBefore node.nextSibling() != tree.find('node_2'), instead it is: " + node.nextSibling().element.id);
      
    if(node.element.parentNode != parent.element)
      log("after insertBefore node.element.parentNode != parent.element, instead it is: " + node.element.parentNode.id)
  
    if(node.element.nextSibling.nextSibling != tree.find('node_2').element)
      log("after insertBefore node.element.nextSibling.nextSibling != tree.find('node_2').element, instead it is: " + node.element.nextSibling.nextSibling.id)
  }
}

log('starting sortable tree tests ...')
for(i in tests) { tests[i](); }
log('finished sortable tree tests.')
