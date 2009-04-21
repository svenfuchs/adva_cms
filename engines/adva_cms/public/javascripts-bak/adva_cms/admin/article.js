var ArticleSearch = Class.create();

ArticleSearch.create = function() { 
  var search = new ArticleSearch('article-search', [
    { keys: ['category'],              show: ['categories'],  hide: ['query', 'button'] },
    { keys: ['title', 'body', 'tags'], show: ['query'],       hide: ['categories', 'button'] },
    { keys: ['draft'],                 show: ['button'],      hide: ['query', 'categories'] }
  ], 'categories');
  search.onChange($('filter_list'));
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
    $F(this) ? $('article_published_at_wrapper').hide() : $('article_published_at_wrapper').show();
  }
}

Event.addBehavior({
  '#article_draft':         function() { Event.observe(this, 'change', ArticleForm.saveDraft.bind(this)); },
  '#article_search':        function() { ArticleSearch.create();  },
  '#content_locale:change': function() { window.location.href = '?cl=' + this.value; }
  // '#revisionnum':  function() { Event.observe(this, 'change', ArticleForm.getRevision.bind(this)); },
});