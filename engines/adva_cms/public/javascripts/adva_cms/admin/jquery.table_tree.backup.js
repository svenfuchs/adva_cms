TableTree = {
	tableDnDOptions: {
		onDragClass: 'drag',
	  onDragStart: function(table, row) {
			row.level = 1;
			TableTree.startOffset = jQuery.tableDnD.mouseOffset.x;
			$(row).mousemove(TableTree.mousemove);
			if (node = $(row).ttnode()) node.dragStart();
		},
		onDrag: function(table, row) {
			TableTree.current_table.dirty = true;
			if (node = $(row).ttnode()) node.update_children();
		},
		onDrop: function(table, row) {
			$(row).unbind('mousemove', TableTree.mousemove);
			if (node = $(row).ttnode()) node.drop();
			TableTree.current_table.rebuild();
			TableTree.current_table.update_remote(row);
		},
		onAllowDrop: function(draggedRow, row, movingDown) {
			var node = $(row).ttnode();
			next = movingDown ? $(node.next_row_sibling()).ttnode() : node;
			if (next) {
				level = next.parent.level ? next.parent.level : 0;
				if (level >= $(draggedRow).ttnode().level) return false;
			}
			return $(row).ttnode() ? true : false;
		}
	},
	toggle: function(table, type, collection_url) {
		TableTree.current_table ? TableTree.teardown(table) : TableTree.setup(table, type, collection_url);
	},
	setup: function(table, type, collection_url) {
		table.tableDnD(TableTree.tableDnDOptions);
		TableTree.current_table = new TableTree.Table($(table).get(0), type, collection_url);
		TableTree.current_table.setSortable();
	},
	teardown: function(table) {
		// TableTree.current_table.update_remote();
		jQuery.tableDnD.teardown(table);
		TableTree.current_table.setUnsortable();
		TableTree.current_table = null;
	},
	level: function(element) {
		var match = element.className.match(/level_([\d]+)/);
		return match ? parseInt(match[1]) : 0;
	},
	setSortable: function(element) {
		if (element.tagName != 'TD') return
		$('a', element).each(function() {
			$(this).hide();
			element.appendChild(document.createTextNode($(this).text()))
		});
	},
	setUnsortable: function(element) {
		if (element.tagName != 'TD') return;
		$('a', element).each(function() { $(this).show(); });
		$('img.spinner', element).remove();
		element.removeChild(element.lastChild);
	},
	mousemove: function(event) {
		var offset = jQuery.tableDnD.getMouseOffset(this, event).x - TableTree.startOffset;
		if(offset > 25) {
			TableTree.current_table.dirty = true;
			$(this).ttnode().increment_level(event);
		} else if(offset < -25) {
			TableTree.current_table.dirty = true;
			$(this).ttnode().decrement_level(event);
		}
	},
	Base: function() {},
	Table: function(table, type, collection_url) {
		this.table = table;
		this.type = type;
		this.collection_url = collection_url;
		this.rebuild();
	},
	Node: function(parent, element, level) {
		var _this = this;
		this.parent = parent;
		this.element = element;
		this.level = level;

		this.children = this.find_children().map(function() {
			var level = TableTree.level(this);
			if(level == _this.level + 1) { return new TableTree.Node(_this, this, level); }
		});
	}
}

TableTree.Base.prototype = {
	find_node: function(element) {
    for (var i = 0; i < this.children.length; i++) {
			var child = this.children[i];
			if (this.children[i].element == element) {
				return this.children[i];
			} else {
				var result = this.children[i].find_node(element);
				if (result) return result;
			}
		}
	}
}
TableTree.Table.prototype = jQuery.extend(new TableTree.Base(), {
	rebuild: function() {
		var _this = this;
		this.children = $('tr', this.table).map(function() {
			if(TableTree.level(this) == 1) { return new TableTree.Node(_this, this, 1); }
		});		
	},
	setSortable: function() {
		this.children.each(function() { this.setSortable(); });
	},
	setUnsortable: function() {
		this.children.each(function() { this.setUnsortable(); });
	},
	update_remote: function(row) {
		if(!this.dirty) return;
		this.dirty = false;
		_this = this;

		this.show_spinner(row);
		$.ajax({
		  type: "POST",
			url: this.collection_url,
			data: jQuery.extend(this.serialize(row), { authenticity_token: window._auth_token, '_method': 'put' }),
			success: function(msg) { _this.hide_spinner(row); },
			error:   function(msg) { _this.hide_spinner(row); }
		});
	},
	serialize: function(row) {
		row = $(row).ttnode();
		data = {};
		data[this.type + '[' + row.id() + '][parent_id]'] = row.parent_id();
		data[this.type +'[' + row.id() + '][left_id]'] = row.left_id();
		return data;
	},
	show_spinner: function(row) {
		img = document.createElement('img');
		img.src = '/images/adva_cms/indicator.gif';
		img.className = 'spinner';
		$('td', row)[0].appendChild(img);
	},
	hide_spinner: function(row) {
		cell = $('td', row)[0];
		cell.removeChild(cell.lastChild);
	}
});

TableTree.Node.prototype = jQuery.extend(new TableTree.Base(), {
	find_children: function() {
		var lvl = this.level;
		var stop = false;
		return this.row_siblings().slice(this.row_index() + 1).filter(function() {
			var level = TableTree.level(this);
			if(lvl == level) stop = true; // how to break from a jquery iterator?
			return !stop && lvl + 1 == level;
		});
	},
	depth: function() {
		if (this.children.length > 0) {
			return Math.max.apply(Math, this.children.map(function() { return this.depth() }).get());
		} else {
			return this.level;
		}
	},
	siblings: function() {
		return this.parent.children;
	},
	id: function() {
		return this.element ? this.to_int(this.element.id) : 'null';
	},
	parent_id: function() {
		return this.parent.element ? this.to_int(this.parent.element.id) : 'null';
	},
	left_id: function() {
		left = this.left()
		return left ? this.to_int(left.element.id) : 'null';
	},
	left: function() {
		siblings = this.siblings().get();
		ix = siblings.indexOf(this);
		if(ix > 0) return siblings[ix - 1];
	},
	to_int: function(str) { 
		if(str) return str.replace(/[\D]+/, '') 
	},
	next_row_sibling: function () {
		return this.row_siblings()[this.row_index() + 1];
	},
	row_siblings: function() {
		if(!this._row_siblings) { this._row_siblings = $(this.element).parent().children(); }
		return this._row_siblings;
	},
	row_index: function() {
		return this.row_siblings().get().indexOf(this.element);
	},
	dragStart: function() {
		$(this.element).addClass('drag');
		this.children.each(function() { this.dragStart(); })
	},
	drop: function() {
		$(this.element).removeClass('drag');
		this.children.each(function() { this.drop(); })
		this.adjust_level();
	},
	increment_level: function(event) {
		var prev = $(this.element).prev().ttnode();
		if(!prev || prev.level < this.level || this.depth() >= 5) return;
		this.update_level(event, this.level + 1);
	},
	decrement_level: function(event) {
		if(this.level == 1) return;
		this.update_level(event, this.level - 1);
	},
	update_level: function(event, level) {
		if (event) TableTree.startOffset = jQuery.tableDnD.getMouseOffset(this.element, event).x;
		
		$(this.element).removeClass('level_' + this.level);
		$(this.element).addClass('level_' + level);
		
		this.level = level;	
		this.children.each(function() { this.update_level(event, level + 1); });
	},
	adjust_level: function() {
		var prev = $(this.element).prev().ttnode();
		if(!prev) {
			this.update_level(null, 1);
		} else if(prev.level + 1 < this.level) {
			this.update_level(null, prev.level + 1);
		}
	},
	update_children: function() {
		this.children.each(function() { this.element.parentNode.removeChild(this.element); });
		var _this = this;
		var _next = _this.element.nextSibling;
		this.children.each(function() { _this.element.parentNode.insertBefore(this.element, _next); });
		this.children.each(function() { this.update_children() });
	},
	setSortable: function() {
		$(this.element).children().each(function(ix) { ix == 0 ? TableTree.setSortable(this) : $(this).hide(); });
		this.children.each(function() { this.setSortable(); });
	},
	setUnsortable: function() {
		$(this.element).children().each(function(ix) { ix == 0 ? TableTree.setUnsortable(this) : $(this).show(); });
		this.children.each(function() { this.setUnsortable(); });
	}
});
		
jQuery.fn.extend({
	ttnode: function() {
		var subject = this.push ? this[0] : this;
		return TableTree.current_table.find_node(subject);
	}
});

jQuery.extend(jQuery.tableDnD, {
	teardown: function(table) {
		jQuery('tr', table).each(function() { $(this).unbind('mousedown'); }).css('cursor', 'auto');
		jQuery.tableDnD.dragObject = null;
		jQuery.tableDnD.currentTable = null;
		jQuery.tableDnD.mouseOffset = null;
	}
});

tableDnD {
	toggle: function() {
		if (table.hasClass('tree')) {
			setupTree()
		}
	}
	// aslödkjföksdfk
	Tree {
		
	}
}



