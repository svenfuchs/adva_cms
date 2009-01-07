var SortableList = Class.create({
  initialize: function(element, options) {
    this.element = $(element);
    if(this.element.nodeName != 'TBODY') {
      this.element = $$('#' + this.element.id + ' tbody')[0];
    }
    this.serialize_param = (options && options.serialize_param) || element.id || element;
    this.sortable_options = Object.extend({tag: 'tr'}, options || {});
    this.isSortable = false;
  },      
  toggle: function(link, alternate_link_text) {
    this.original_link_text = this.original_link_text || $(link).innerHTML
    alternate_link_text = alternate_link_text || 'Done reordering'

    if(this.isSortable) {
      this.setUnsortable()
      $(link).update(this.original_link_text)
     this.mapLinks(this.showLink);
    } else {
      this.setSortable()
      $(link).update(alternate_link_text)
      this.mapLinks(this.hideLink);
    }
  },      
  setSortable: function() {
    Element.addClassName(this.element, 'sortable');
    Sortable.create(this.element, this.sortable_options);
    this.isSortable = true; 
  },
  setUnsortable: function() {
    Element.removeClassName(this.element, 'sortable');
    Sortable.destroy(this.element);
    this.isSortable = false; 
  }, 
  rows: function() {
    return this.element.select('tr');
  },
  mapLinks: function(func) {
    this.rows().each(function(row){
      var link = row.select('td a').first();
      func(link.parentNode, link);
    }.bind(this));
  },
  showLink: function(element, link) {
    Element.removeClassName(element, 'sortable');
    element.removeChild(element.firstChild)
    link.style.display = '';
  },
  hideLink: function(element, link) {
    Element.addClassName(element, 'sortable');
    element.insertBefore(document.createTextNode(link.innerHTML), element.firstChild)
    link.style.display = 'none';
  },     
  serialize: function() {
    var pos = 0;
    var params = '';
    this.rows().each(function(tr){
      var match = tr.id.match(/^[\w]+_([\d]*)$/);
      var id = encodeURIComponent(match ? match[1] : null);
      params += (params ? '&' : '') + this.serialize_param + '[' + id + '][position]=' + pos++;
    }.bind(this));
    return params;
  }
});