var Flash = new Object();

Flash.data = {};

Flash.transferFromCookies = function() {
  var data = JSON.parse(unescape(Cookie.get("flash")));
  if(!data) data = {};
  Flash.data = data;
  Cookie.erase("flash");
};

Flash.writeDataTo = function(name, element) {
  element = $(element);
  var content = "";
  if(Flash.data[name]) {
    content = Flash.data[name].toString().gsub(/\+/, ' ');
  }
  element.innerHTML = unescape(content);
};
