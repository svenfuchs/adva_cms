var AjaxfiedLaterDude = {
	loadCalendarPartial: function(event) {
		new Ajax.Request(event.target.href + '.js', {
			method: 'get' });
		event.preventDefault();
	}
}


Event.addBehavior({
	'.calendar .previous_month a':   function() { Event.observe(this, 'click', AjaxfiedLaterDude.loadCalendarPartial.bind(this)); },
	'.calendar .next_month a':   function() { Event.observe(this, 'click', AjaxfiedLaterDude.loadCalendarPartial.bind(this)); }
});