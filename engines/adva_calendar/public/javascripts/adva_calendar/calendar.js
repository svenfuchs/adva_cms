var AjaxfiedLaterDude = {
	loadCalendarPartial: function(event) {
		new Ajax.Request(event.target.href + '.js', {
			method: 'get' });
		event.preventDefault();
	},
	attachEvents: function() {
		Event.addBehavior({
			'.calendar a.nav':   function() { Event.observe(this, 'click', AjaxfiedLaterDude.loadCalendarPartial.bind(this)); },
			'.calendar a.nav':   function() { Event.observe(this, 'click', AjaxfiedLaterDude.loadCalendarPartial.bind(this)); }
		});		
	}
}

AjaxfiedLaterDude.attachEvents();