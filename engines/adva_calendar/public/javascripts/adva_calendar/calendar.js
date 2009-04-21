Event.onReady(function() {
	// updates .calendar and .events with current calendar sheet and events list
	if ($$('.calendar_cell').length != 0) {
		new Ajax.Request($$('.calendar a')[0].href.replace(/([\d\/]*)?\.html/, '.js'), { method: 'get' });
	}
});