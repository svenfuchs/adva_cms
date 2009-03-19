Filter = {
	select_filter: function(event) {
		var set = this.parentNode;
		var name = this.options[this.selectedIndex].value;

		Element.select(set, '.filter').each(function(e) { e.removeClassName('selected'); });
		Element.select(set, '.filter_' + name)[0].addClassName('selected');
	},
	add_filter: function(event) {
		this.blur();
		var form = this.parentNode.parentNode.parentNode;
		var set = this.parentNode.parentNode.cloneNode(true);

		form.insertBefore(set, this.parentNode.nextSibling);
		Element.select(set, '.remove_filter')[0].removeClassName('first')

		Event.observe(Element.select(set, '.selected_filter')[0], 'click', Filter.select_filter);
		Event.observe(Element.select(set, '.add_filter')[0], 'click', Filter.add_filter);
		Event.observe(Element.select(set, '.remove_filter')[0], 'click', Filter.remove_filter);

		event.preventDefault();
	},
	remove_filter: function(event) {
		this.blur();
		var filter = this.parentNode.parentNode;
		Element.remove(filter);
		event.preventDefault();
	}
}

Event.addBehavior({
  '.selected_filter:click': Filter.select_filter,
	'.add_filter:click':      Filter.add_filter,
	'.remove_filter:click':   Filter.remove_filter
});
