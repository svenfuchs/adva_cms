var Spotlight = Class.create();
Spotlight.prototype = {
  initialize: function(form, searchbox) {
    var options, types, attributes = [];
    this.form = $(form);
    var search = $(searchbox);
    Event.observe(searchbox, 'click', function(e) { Event.element(e).value = '' });
    search.setAttribute('autocomplete', 'off');
    
    new Form.Element.Observer(searchbox, 1,  this.search.bind(this));
    
    types = $A($('type').getElementsByTagName('LI'));
    attributes = $A($('attributes').getElementsByTagName('LI'));
    attributes = attributes.reject(function(e) { return e.id.length < 1 });
    attributes.push(types);
    attributes = attributes.flatten();
    attributes.each(function(attr) {
      Event.observe(attr, 'click', this.onClick.bindAsEventListener(this));
    }.bind(this));
  },
  
  onClick: function(event) {
    var element = Event.element(event), check;
    if(element.tagName != 'LI') element = Event.findElement(event, 'LI');
    var check = ($(element.id + '-check'));
    
    if(Element.hasClassName(element, 'pressed')) {
      Element.removeClassName(element, 'pressed');
      check.removeAttribute('checked');
    } else {
      Element.addClassName(element, 'pressed');
      check.setAttribute('checked', 'checked');
    }    
    this.search();
  },
  
  search: function(searchbox) {
    $('search-assets-spinner').show();
    $('page').value = $('page').value || '1';
    new Ajax.Request(this.form.action, { asynchronous: true, evalScripts: true, method: 'get', 
	                                     parameters: Form.serialize(this.form) });                                  
    return false;
  }
}