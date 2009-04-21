$(document).ready(function() {
	if (reorder = $('a.reorder')) {
		reorder.click(function(event) {
			$(this).parent().toggleClass('active');
			TableTree.toggle($('table.list'), this.id.replace('reorder_', ''), this.href);
			event.preventDefault();
			return false;
		})
	}
});