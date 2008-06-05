Asset = {
  addInput: function() {
    var list = $('files'), copyFrom = list.down(), tagall = $('tagall-files');
    var newNode = copyFrom.cloneNode(true), files = list.getElementsByTagName('p');
    var close = $(newNode).select('.remove-file')[0]; 
    Element.remove($(newNode).select('.tagall-files')[0]);
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
    var inputs = $(form_id).getInputs('text', 'assets[][tag_list]');
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

var TinyTab = Class.create();
TinyTab.prototype = {
  initialize: function(element, panels) {
		this.container = $(element)
    if(this.container) {
			var tabs = $(this.container).select('.tabs')[0];
	    tabs.cleanWhitespace();
	    this.tabs = $A(tabs.childNodes);

	    this.panels = $(this.container).select('.panel');
			this.showPanel(this.panels[0]);

			this.selectFirstTab();
	    this.tabs.each(function(link) {
	      Event.observe(link, 'click', function(event) {
					this.selectTab(Event.element(event).parentNode)
	    		Event.stop(event);
	      }.bindAsEventListener(this));
	    }.bind(this));
		}
  },
	selectedTab: function(element) {
		return this.tabs.detect(function(tab){ return tab.hasClassName('selected') })
	},
	selectFirstTab: function() {
		var tab = this.tabs.detect(function(tab){ return tab.visible() });
		this.selectTab(tab);
	},
	selectTab: function(element) {
		this.unselectTab();
    element.addClassName('selected');
    this.showPanel(element);
	},
	unselectTab: function() {
		var selected = this.selectedTab();
		if(selected) selected.removeClassName('selected');
	},
	showPanel: function(element) {
    this.panels.each(function(panel) { Element.hide(panel) });
    $(element.getAttribute('id').replace('tab-', '')).show();
	}
};

var Spotlight = Class.create();
Spotlight.prototype = {
  initialize: function(form, searchbox) {
    var options, types, attributes = [];
    this.form = $(form);
    var search = $(searchbox);
    Event.observe(searchbox, 'click', function(e) { Event.element(e).value = '' });
    search.setAttribute('autocomplete', 'off');
    
    new Form.Element.Observer(searchbox, 1,  this.search.bind(this));
    
    types = $A($('type').getElementsByTagName('LI'));
    attributes = $A($('attributes').getElementsByTagName('LI'));
    attributes = attributes.reject(function(e) { return e.id.length < 1 });
    attributes.push(types);
    attributes = attributes.flatten();
    attributes.each(function(attr) {
      Event.observe(attr, 'click', this.onClick.bindAsEventListener(this));
    }.bind(this));
  },
  
  onClick: function(event) {
    var element = Event.element(event), check;
    if(element.tagName != 'LI') element = Event.findElement(event, 'LI');
    var check = ($(element.id + '-check'));
    
    if(Element.hasClassName(element, 'pressed')) {
      Element.removeClassName(element, 'pressed');
      check.removeAttribute('checked');
    } else {
      Element.addClassName(element, 'pressed');
      check.setAttribute('checked', 'checked');
    }    
    this.search();
  },
  
  search: function(searchbox) {
    $('search-assets-spinner').show();
    $('page').value = $('page').value || '1';
    new Ajax.Request(this.form.action, { asynchronous: true, evalScripts: true, method: 'get', 
																		     parameters: Form.serialize(this.form) });                                  
    return false;
  }
}

Abstract.SmartEventObserver = Class.create(Abstract.EventObserver, {
  onElementEvent: function(event) {
    var value = this.getValue();
    if (this.lastValue != value) {
      this.callback(Event.element(event), value, event);
      this.lastValue = value;
    }
  }
});

var SmartForm = {};
SmartForm.EventObserver = Class.create(Abstract.EventObserver, {
  onElementEvent: function(event) {
    var value = this.getValue();
    if (this.lastValue != value) {
      this.callback(Event.element(event), value, event);
      this.lastValue = value;
    }
  },
  getValue: function() {
    return Form.serialize(this.element);
  }
});

var ArticleSearch = Class.create();
ArticleSearch.create = function() { 
	var search = new ArticleSearch('article-search', [
    {keys: ['category'],              show: ['categories'],  hide: ['query', 'button']},
    {keys: ['title', 'body', 'tags'], show: ['query'],       hide: ['categories', 'button']},
    {keys: ['draft'],                 show: ['button'],      hide: ['query', 'categories']}
  ], 'categories');
	search.onChange($('filterlist'));
	return search;
}
ArticleSearch.prototype = {
  initialize: function(form, conditions, triggersSubmit) {
    this.element = $(form);
    this.conditions = $A(conditions);
    this.triggersSubmit = $(triggersSubmit);
    if(!this.element) return;    
    new SmartForm.EventObserver(this.element, this.onChange.bind(this));
  },  
  onChange: function(element, event) {
    if(element == this.triggersSubmit) {
      this.element.submit();
      return false;
    }    
    this.conditions.each(function(condition) {
      if(condition.keys.include($F(element))) {
        $A(condition.show).each(function(e) { $(e).show(); });
        $A(condition.hide).each(function(e) { $(e).hide(); });
      }
    }.bind(this));
    return false;
  }
}

var ArticleForm = {
  saveDraft: function() {
		$F(this) ? $('publish-date').hide() : $('publish-date').show();
  }
}

var AssetWidget = {
	siteId: function() {
		return location.href.match(/sites\/([0-9]+)\//)[1];
	},
	assetId: function(element) {
		return element.getAttribute('id').match(/-(\d+)$/)[1];
	},
	memberId: function() {
		return location.href.match(/\/([0-9]+)\/(new|edit)/)[1];
	},
	assetsUrl: function() {
		return '/admin/sites/' + this.siteId() + '/assets';
	},
	collectionUrl: function(element) {
		return this.assetsUrl() + '/' + this.assetId(element) + '/contents';
	},
	memberUrl: function(element) {
		return this.collectionUrl(element) + '/' + this.memberId();
	},
  attachAsset: function(element, authenticityToken) {
    if(!this.isAttached(element)) {
	    new Ajax.Request(this.collectionUrl(element), { 'method': 'post', 'parameters': { 'content_id': this.memberId(), 'authenticity_token': authenticityToken }});
		}
  },
  detachAsset: function(element, authenticityToken) {
    if(this.isAttached(element)) {
			new Ajax.Request(this.memberUrl(element), { 'method': 'post', 'parameters': { '_method': 'delete', 'authenticity_token': authenticityToken }});
		}
  },
	isAttached: function(element) {
		return $('attached-asset-' + this.assetId(element)) ? true : false;
	},
	updateSelected: function() {
		if(!$('assets-widget')) return;
		var selectedIds = this.selectedAssetIds();
		this.updateSelectedTab(selectedIds.length > 0);
		this.updateSelectedAssets(selectedIds);
	},
	updateSelectedTab: function(show) {
		show ? this.showSelectedTab() : this.hideSelectedTab();
		if(!TinyTab.assets.selectedTab()){
			TinyTab.assets.selectFirstTab();
		}
	},
	showSelectedTab: function() {
		$('tab-attached-assets').show();
	},
	hideSelectedTab: function() {
		$('tab-attached-assets').hide();
		if(TinyTab.assets.selectedTab() == $('tab-attached-assets')) {
			TinyTab.assets.unselectTab();
		}
		$('attached-assets').hide();
	},
	updateSelectedAssets: function(ids) {
		['latest', 'bucket'].each(function(prefix) {
			$$('.' + prefix + '-asset').each(function(asset) { 
				asset.removeClassName('selected'); 
			});
			ids.each(function(id) { 			
				var asset = $(prefix + '-asset-' + id);
				if (asset) { asset.addClassName('selected'); }
		  });
		}.bind(this));		
	},
	selectedAssetIds: function() {
		return $$('.attached-asset').collect(function(asset) { return asset.getAttribute('id').match(/-(\d+)$/)[1]; });
	},	
  showAttachTools: function(id) {
		['attach', 'detach'].each(function(prefix){ $(prefix + '-' + id).show(); })
  },  
  hideAttachTools: function(id) {
		['attach', 'detach'].each(function(prefix){ $(prefix + '-' + id).hide(); })
  },
	search: function(query) {
    if(!query) return;
    $('search-assets-spinner').show();
    new Ajax.Request(this.assetsUrl(), { parameters: { query: escape(query), limit: 6, source: 'widget' }, method: 'get' });
	},
  upload: function(element, authenticityToken) {
		if(!$('asset-upload-frame')) {
			document.body.appendChild(new Element('iframe', { id: 'asset-upload-frame', name: 'asset-upload-frame', style: 'display: none;' }));
		}
		var form = new Element('form', { action: this.assetsUrl(), method: 'post', enctype: 'multipart/form-data', target: 'asset-upload-frame', style: 'display: none;' });
		form.appendChild(new Element('input', { type: 'hidden', name: 'authenticity_token', value: authenticityToken}));
		form.appendChild(new Element('input', { type: 'hidden', name: 'respond_to_parent', value: '1'}));
		form.appendChild(element.cloneNode(true));
		document.body.appendChild(form);
		form.submit();
		Element.remove(form);
  }	
};

var Comments = {
  filter: function() {
    location.href = "?filter=" + $F(this).toLowerCase();
  }
}

if (SortableTree) Object.extend(SortableTree.prototype, {
	toggle: function(link, alternate_link_text) {
		this.original_link_text = this.original_link_text || $(link).innerHTML
		alternate_link_text = alternate_link_text || 'Done reordering'
	
		this.toggleSortable();
		if(this.isSortable) {
			$(link).update(alternate_link_text)
			this.mapLinks(this.root.children, this.hideLink);
		} else {
			$(link).update(this.original_link_text)
			this.mapLinks(this.root.children, this.showLink);
		}
	},
	mapLinks: function(nodes, func) {
		nodes.each(function(node){
			var link = this.findLink(node.element.childNodes);
			func(node.element, link);
			this.mapLinks(node.children, func);
		}.bind(this));
	},
	findLink: function(elements) {
		for(var i = 0; i < elements.length; i++) {
			if(elements[i].tagName == 'A') return elements[i];
		}
	},
	showLink: function(element, link) {
		element.removeChild(element.firstChild)
		link.style.display = null;
	},
	hideLink: function(element, link) {
		span = Element.extend(document.createElement('span')).update(link.innerHTML);
		element.insertBefore(span, element.firstChild)
		link.style.display = 'none';
	}
});
    
var ArticlesList = Class.create({
  initialize: function(element, options) {
    this.element = $(element);
		if(this.element.nodeName != 'TBODY') {
			this.element = $$('#' + element + ' tbody')[0];
		}
    this.sortable_options = Object.extend({tag: 'tr'}, options || {});
		this.isSortable = false;
  },      
  toggle: function(link, alternate_link_text) {    		
    this.original_link_text = this.original_link_text || $(link).innerHTML
		alternate_link_text = alternate_link_text || 'Done reordering'

		if(this.isSortable) {
		  this.setUnsortable()
			$(link).update(this.original_link_text)
 		this.mapLinks(this.showLink);
		} else {
		  this.setSortable()
			$(link).update(alternate_link_text)
			this.mapLinks(this.hideLink);
		}
  },      
  setSortable: function() {
    Element.addClassName(this.element, 'sortable');
    Sortable.create(this.element, this.sortable_options);
    this.isSortable = true; 
  },
  setUnsortable: function() {
    Element.removeClassName(this.element, 'sortable');
    Sortable.destroy(this.element);
    this.isSortable = false; 
  }, 
  rows: function() {
    return this.element.select('tr');
  },
	mapLinks: function(func) {
		this.rows().each(function(row){
		  var link = row.select('td a').first();
			func(link.parentNode, link);
		}.bind(this));
	},
	showLink: function(element, link) {
    Element.removeClassName(element, 'sortable');
		element.removeChild(element.firstChild)
		link.style.display = null;
	},
	hideLink: function(element, link) {
    Element.addClassName(element, 'sortable');
		element.insertBefore(document.createTextNode(link.innerHTML), element.firstChild)
		link.style.display = 'none';
	},     
  serialize: function() {
    var pos = 0;
    var params = '';
    this.rows().each(function(tr){
      var match = tr.id.match(/^[\w]+_([\d]*)$/);
      var id = encodeURIComponent(match ? match[1] : null);
      params += (params ? '&' : '') + 'articles[' + id + '][position]=' + pos++;
      params += (params ? '&' : '') + 'articles[' + id + '][blah]=' + pos;
    }.bind(this));
    return params;
  }
});

var SiteSelect = Class.create();
SiteSelect.change = function(event) {
  location.href = event.element().getValue();
}

Event.addBehavior({
  '#article-draft':         function() { Event.observe(this, 'change', ArticleForm.saveDraft.bind(this)); },
  '#article-search':        function() { ArticleSearch.create();  },
  '#comments-filter':       function() { Event.observe(this, 'change', Comments.filter.bind(this)); },
  '#asset-add-file:click':  function() { return Asset.addInput(); },
  '#tagall-files:click':    function() { Asset.applyTagsToAll('asset_form'); },
  '#assets-search-form':    function() { window.spotlight = new Spotlight('assets-search-form', 'assets-search-query'); },  
  // '#revisionnum':        function() { Event.observe(this, 'change', ArticleForm.getRevision.bind(this)); },

	'.assets-row div:mouseover': 			    function() { Element.getElementsBySelector(this, '.asset-tools').first().show(); },
	'.assets-row div:mouseout':  			    function() { Element.getElementsBySelector(this, '.asset-tools').first().hide(); },

  '#assets-widget .attach-asset:click': function() { AssetWidget.attachAsset(this, $('content_form').authenticity_token.value); return false; },
  '#assets-widget .detach-asset:click': function() { AssetWidget.detachAsset(this, $('content_form').authenticity_token.value); return false; },
  '#assets-widget .asset:mouseover': 	  function() { AssetWidget.showAttachTools(this.getAttribute('id')); },
  '#assets-widget .asset:mouseout': 		function() { AssetWidget.hideAttachTools(this.getAttribute('id')); },

	'#search-assets-button:click':        function(event) { AssetWidget.search($F('search-assets-query')); },
	'#search-assets-query:keypress':      function(event) { if(event.keyCode == Event.KEY_RETURN) { AssetWidget.search($F('search-assets-query')); Event.stop(event); } },
	'#upload-assets-button:click':        function(event) { AssetWidget.upload($('asset-uploaded-data'), $('content_form').authenticity_token.value);},
  '#site-select':           function() { Event.observe(this, 'change', SiteSelect.change.bind(this)); }
})                                      

Event.onReady(function() {
  // new DropMenu('select');
  TinyTab.assets = new TinyTab('assets-widget', 'panels');
	AssetWidget.updateSelected();
});

function log(line) {
  $('log').update($('log').innerHTML + "<p>" + line + "</p>")
}

