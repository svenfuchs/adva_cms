TableTree = {
	toggle: function(selector) {
		TableTree.current_table ? TableTree.teardown() : TableTree.setup(selector);
	},
	setup: function(table) {
		TableTree.current_table = new TableTree.Table($(table).get(0));
		TableTree.current_table.setSortable();
	},
	teardown: function() {
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
		if (element.tagName != 'TD') return
		$('a', element).each(function() { $(this).show(); });
		element.removeChild(element.lastChild);
	},
	mousemove: function(event) {
		var offset = jQuery.tableDnD.getMouseOffset(this, event).x - TableTree.startOffset;
		if(offset > 25) {
			$(this).ttnode().increment_level(event);
		} else if(offset < -25) {
			$(this).ttnode().decrement_level(event);
		}
	},
	Base: {
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
	},
	Table: function(table) {
		this.table = table;
		this.rebuild();
	},
	Node: function(parent, element, level) {
		var _this = this;
		this.parent = parent;
		this.element = element;
		this.level = level;

		this.children = this.findChildren().map(function() {
			var level = TableTree.level(this);
			if(level == _this.level + 1) { return new TableTree.Node(_this, this, level); }
		});
	}
}

TableTree.Table.prototype = jQuery.extend(TableTree.Base, {
	rebuild: function() {
		var _this = this;
		this.children = $('tbody tr', this.table).map(function() {
			if(TableTree.level(this) == 1) { return new TableTree.Node(_this, this, 1); }
		});		
	},
	setSortable: function() {
		this.children.each(function() { this.setSortable(); });
	},
	setUnsortable: function() {
		this.children.each(function() { this.setUnsortable(); });
	}
});

TableTree.Node.prototype = jQuery.extend(TableTree.Base, {
	findChildren: function() {
		var lvl = this.level;
		var stop = false;
		return this.siblings().slice(this.index() + 1).filter(function() {
			var level = TableTree.level(this);
			if(lvl == level) stop = true; // how to break from a jquery iterator?
			return !stop && lvl + 1 == level;
		});
	},
	siblings: function() {
		if(!this._siblings) { this._siblings = $(this.element).parent().children(); }
		return this._siblings;
	},
	depth: function() {
		if (this.children.length > 0) {
			return Math.max.apply(Math, this.children.map(function() { return this.depth() }).get());
		} else {
			return this.level;
		}
	},
	index: function() {
		return this.siblings().get().indexOf(this.element);
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

$(document).ready(function() {
	TableTree.toggle('#sections.list');

	$("#sections.list").tableDnD({
		onDragClass: 'drag',
		onDragStart: function(table, row) {
			row.level = 1;
			TableTree.startOffset = jQuery.tableDnD.mouseOffset.x;
			$(row).mousemove(TableTree.mousemove);
			if (node = $(row).ttnode()) node.dragStart();
		},
		onDrag: function(table, row) {
			if (node = $(row).ttnode()) node.update_children();
		},
		onDrop: function(table, row) {
			$(row).unbind('mousemove', TableTree.mousemove);
			if (node = $(row).ttnode()) node.drop();
			TableTree.current_table.rebuild();
		},
		onAllowDrop: function(draggedRow, row) {
			return $(row).ttnode() ? true : false;
		}
	});
});
