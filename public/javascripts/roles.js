function authorize_elements(roles) {
	if(roles.include('superuser')) {
		var elements = $$(".requires-role");
	} else {
		var elements = roles.map(function(role){ $$("." + role) }).flatten();
	}
  elements.each(function(element) {
    element.removeClassName('requires-role');
  });
}
