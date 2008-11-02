function authorize_elements(roles) {
	if(roles.include('superuser')) {
		var elements = $$(".visible-for");
	} else {
		var elements = roles.map(function(role){ return $$("." + role) }).flatten();
	}
  elements.each(function(element) {
		if(element) {
    	element.removeClassName('visible-for');
		}
  });
}

Event.onReady(function() {
	authorize_elements(new Array('anonymous'))
});