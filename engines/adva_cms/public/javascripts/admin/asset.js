Asset = {
  addInput: function() {
    var list = $('files'), copyFrom = list.down(), tagall = $('tagall_files');
    var newNode = copyFrom.cloneNode(true), files = list.getElementsByTagName('p');
		for(c=0; c < newNode.childNodes.length; c++) {
			if(newNode.childNodes[c].id == undefined) { continue; }
			newNode.childNodes[c].id = newNode.childNodes[c].id.replace(/[0-9]+/, list.childNodes.length-2);
			newNode.childNodes[c].name = newNode.childNodes[c].name.replace(/[0-9]+/, list.childNodes.length-2);
		}
    var close = $(newNode).select('.remove_file')[0]; 
    Element.remove($(newNode).select('.tagall_files')[0]);
    Event.observe(close, 'click', function(e) { 
      Event.findElement(e, 'p').remove(); 
      if(tagall.visible() && files.length == 1) tagall.hide();
    });
    close.show();
    if(!tagall.visible() && files.length > 0) tagall.show();
    list.appendChild(newNode);
  },
  
  removeInput: function(input, formId, inputClass) {
    var length = $$('#' + formId + ' .' + inputClass).findAll(function(e) { return e.visible(); }).length;
    if(length == 2) this.showTitle('asset_title');
    $(input).up('dd').visualEffect('drop_out');    
    return false;
  },
  
  hideTitle: function(titleId) {
    var dd = $(titleId).up('dd');
    var dt = dd.previous('dt');
    [dd, dt].each(Element.hide);
  },
  
  showTitle: function(titleId) {
    var dd = $(titleId).up('dd');
    var dt = dd.previous('dt');
    [dd, dt].each(Element.show);
  },

	applyTagsToAll: function(form_id) {
    var inputs = $(form_id).getInputs('text', 'assets[0][tag_list]');
    var tags = $F(inputs.first()).split(' ');
    tags = tags.collect(function(t) { return t.strip(); });
    inputs.each(function(e, index) {
      if(index > 0) {
        var localtags = $F(e).split(' ').findAll(function(t) { return t.length > 0 });
        localtags = localtags.collect(function(t) { return t.strip(); });
        localtags.push(tags);
        e.value = localtags.flatten().uniq().join(' ');
      }
    }
  )}
}

Event.addBehavior({
  '#asset_add_file:click':  function() { return Asset.addInput(); },
  '#tagall_files:click':    function() { Asset.applyTagsToAll('asset_form'); },
  '#assets_search_form':    function() { window.spotlight = new Spotlight('assets_search_form', 'assets_search_query'); },  
	'.assets_row div:mouseover': 			    function() { Element.getElementsBySelector(this, '.asset_tools').first().show(); },
	'.assets_row div:mouseout':  			    function() { Element.getElementsBySelector(this, '.asset_tools').first().hide(); }
});

