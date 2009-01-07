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


Event.addBehavior({
  '#article-draft':   function() { Event.observe(this, 'change', ArticleForm.saveDraft.bind(this)); },
  '#article-search':  function() { ArticleSearch.create();  }
  // '#revisionnum':  function() { Event.observe(this, 'change', ArticleForm.getRevision.bind(this)); },
});