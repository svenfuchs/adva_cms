var ArticleSearch = Class.create();
ArticleSearch.create = function() { 
	var search = new ArticleSearch('article-search', [
    {keys: ['category'],              show: ['categories'],  hide: ['query', 'button']},
    {keys: ['title', 'body', 'tags'], show: ['query'],       hide: ['categories', 'button']},
    {keys: ['draft'],                 show: ['button'],      hide: ['query', 'categories']}
  ], 'categories');
	search.onChange($('filterlist'));
	return search;
}
ArticleSearch.prototype = {
  initialize: function(form, conditions, triggersSubmit) {
    this.element = $(form);
    this.conditions = $A(conditions);
    this.triggersSubmit = $(triggersSubmit);
    if(!this.element) return;    
    new SmartForm.EventObserver(this.element, this.onChange.bind(this));
  },  
  onChange: function(element, event) {
    if(element == this.triggersSubmit) {
      this.element.submit();
      return false;
    }    
    this.conditions.each(function(condition) {
      if(condition.keys.include($F(element))) {
        $A(condition.show).each(function(e) { $(e).show(); });
        $A(condition.hide).each(function(e) { $(e).hide(); });
      }
    }.bind(this));
    return false;
  }
}

var ArticleForm = {
  saveDraft: function() {
		$F(this) ? $('publish-date').hide() : $('publish-date').show();
  }
}

var ArticlesList = Class.create({
  initialize: function(element, options) {
    this.element = $(element);
		if(this.element.nodeName != 'TBODY') {
			this.element = $$('#' + element + ' tbody')[0];
		}
    this.sortable_options = Object.extend({tag: 'tr'}, options || {});
		this.isSortable = false;
  },      
  toggle: function(link, alternate_link_text) {    		
    this.original_link_text = this.original_link_text || $(link).innerHTML
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
		link.style.display = null;
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
      params += (params ? '&' : '') + 'articles[' + id + '][position]=' + pos++;
      params += (params ? '&' : '') + 'articles[' + id + '][blah]=' + pos;
    }.bind(this));
    return params;
  }
});

Event.addBehavior({
  '#article-draft':   function() { Event.observe(this, 'change', ArticleForm.saveDraft.bind(this)); },
  '#article-search':  function() { ArticleSearch.create();  }
  // '#revisionnum':  function() { Event.observe(this, 'change', ArticleForm.getRevision.bind(this)); },
});