var CommentSearch = Class.create();
CommentSearch.create = function() { 
	var search = new CommentSearch('comment-search', [
    {keys: ['all'], show: ['button'], hide: ['states', 'query']},
	{keys: ['body', 'author_name', 
			'author_email', 'author_homepage'], show: ['query'],       		hide: ['button', 'states']},
    {keys: ['state'],                 			show: ['button', 'states'], hide: ['query']}
  ], 'all');
	search.onChange($('filterlist'));
	return search;
}
CommentSearch.prototype = {
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

Event.addBehavior({
  '#comment-search':  function() { CommentSearch.create();  }
});