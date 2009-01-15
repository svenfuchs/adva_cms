var CalendarSearch = Class.create();
CalendarSearch.create = function() { 
	var search = new CalendarSearch('calendar-search', [
    {keys: ['category'],              show: ['categories'],  hide: ['query', 'button']},
    {keys: ['title', 'body', 'tags'], show: ['query'],       hide: ['categories', 'button']}
  ], 'categories');
	search.onChange($('filterlist'));
	return search;
}
CalendarSearch.prototype = {
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

var CalendarEventForm = {
  saveDraft: function() {
		$F(this) ? $('publish-date').hide() : $('publish-date').show();
  },
	toggleLocation: function(event) {
		if (event.target.value == "") {
			$('new_location').show();
		} else {
			$('new_location').hide();
		}
	},
	toggleEndDate: function() {
		$F(this) ? $('end-date').hide() : $('end-date').show();
	}
}

Event.addBehavior({
	'#calendar-event-draft':   function() { Event.observe(this, 'change', CalendarEventForm.saveDraft.bind(this)); },
	'#calendar_event_all_day':   function() { Event.observe(this, 'change', CalendarEventForm.toggleEndDate.bind(this)); },
  '#calendar_event_location_id':   function() { Event.observe(this, 'change', CalendarEventForm.toggleLocation.bind(this)); },
  '#calendar-search':  function() { CalendarSearch.create();  }
});