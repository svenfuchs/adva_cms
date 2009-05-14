var Flash = {
	transferFromCookies: function() {
	  var data = JSON.parse(unescape(Cookie.get('flash')).replace(/\+/g, ' '));
	  if(!data) data = {};
	  Flash.data = data;
	  Cookie.erase('flash');
	},
	show: function(type, message) {
	  if(!Flash.data || Flash.data == {}) Flash.transferFromCookies();

    var flash = $('#flash_' + type);
    // if no message is given, look it up in the hash
    if(!message) var message = Flash.data[type];

    if(!message) return;
    
    if(message.toString().match(/<li/)) message = "<ul>" + message + '</ul>'
    flash.html(message);

		flash.show();
	},
	
	showAll: function() {
	  $.each(['notice', 'error'], function() {
      Flash.show(this.toString());
    })
	},
	
	error: function(message) {
    this.show('error', message);
  },

  notice: function(message) {
    this.show('notice', message);
  }
}

$(document).ready(function() {
  Flash.showAll();
});
