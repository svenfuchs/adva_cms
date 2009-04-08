Tabs = {
	hide_all: function() {
		$$(".tabs > ul li").each(function(el){ el.removeClassName('active')})
		$$(".tabs .tab").each(function(el){ el.removeClassName('active')})
	},
	click: function(el) {
		var id = 'tab_' + el.href.split('#')[1]
		Tabs.hide_all(); // hrmm ...
		$(id).addClassName('active');
		$(el.parentNode).addClassName('active');
	}
}

Event.addBehavior({
	'.tabs > ul li a:click': function() { Tabs.click(this) },
});	
