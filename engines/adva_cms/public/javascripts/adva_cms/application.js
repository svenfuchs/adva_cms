var LoginLinks = {
	init: function() {
		var user_id = Cookie.get('uid');
		var user_name = unescape(Cookie.get('uname')).replace(/\+/g, " ");
		try { 
			LoginLinks.update_user_links(user_name) 
		} catch(err) {}
		if (user_id) {
			try { 
				$('#logout_links').show(); 
				$('#login_links').hide();
			} catch(err) {}
		}
	},

	update_user_links: function(user_name) {
		if($('#logout_link')) $('#logout_link').href = $('#logout_link').href + "?return_to=" + escape(document.location.href);
		if($('#login_link'))  $('#login_link').href  = $('#login_link').href  + "?return_to=" + escape(document.location.href);
		
		$('span.user_name').each(function() {
		  $(this).html(user_name);
		});
	}
};

URI.parseOptions.strictMode = true;

$(document).ready(function() {
	if($('#logout_links')) {
		LoginLinks.init();
	}
});