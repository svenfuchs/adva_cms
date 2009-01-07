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
		link.style.display = '';
	},
	hideLink: function(element, link) {
		span = Element.extend(document.createElement('span')).update(link.innerHTML);
		element.insertBefore(span, element.firstChild)
		link.style.display = 'none';
	}
});