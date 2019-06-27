tool
extends ScrollContainer

signal end_reached()
signal begin_readched()

export(PackedScene) var item_template
export(PackedScene) var header_template
export(PackedScene) var footer_template
export(int, 0, 1000) var space = 0
export(int, 1, 60) var CACHE_SIZE = 1
export var expand_size_to_parent = false

export(int, "Horizontal", "Vertical") var direction = VERTICAL setget _set_direction
var data_source = [] setget _set_data_source

var _container = Control.new()
var _item_size = Vector2()
var _item_node_cache = []
var _queue_updating = true
var _queue_updating_layout = true
var _last_frame_scroll = 0
var _footer = null
var _header = null
var _header_size = Vector2()
var _footer_size = Vector2()
var _last_top_index = -1

# Queue update the visiable items of the list  
# If `item_count_changed` is `true` the content size will be updated
func queue_update(item_count_changed = false):
	_queue_updating = true
	if item_count_changed:
		self.data_source = data_source

# Force update the list
func queue_update_layout():
	_queue_updating_layout = true

# Show the item
func move_to_item(data):
	var index = data_source.find(data)
	var pos = _get_node_pos_by_index(index)
	if pos.x > 0:
		self.scroll_horizontal = pos.x
	if pos.y > 0:
		self.scroll_vertical = pos.y

# Move to begin position of the list
func move_to_begin():
	self.scroll_vertical = 0
	self.scroll_horizontal = 0

# Get footer node instance
func get_footer():
	return _footer

# Get header node instance
func get_header():
	return _header

var	_size_calculate = null# Item to calculate the item size 

func _init():
	connect("resized", self, "queue_update_layout")
	_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_container)
	self._queue_updating = true

func _enter_tree():
	# header
	if _header == null:
		if typeof(header_template) == TYPE_OBJECT and header_template is PackedScene:
			_header = header_template.instance()
			_container.add_child(_header)
	# footer
	if _footer == null:
		if typeof(footer_template) == TYPE_OBJECT and footer_template is PackedScene:
			_footer = footer_template.instance()
			_container.add_child(_footer)
	# item for item size calculate
	if _size_calculate == null and typeof(item_template) == TYPE_OBJECT and item_template is PackedScene:
		_size_calculate = item_template.instance()
	queue_update_layout()
	# queue_update()

func _exit_tree():
	if _size_calculate != null:
		_size_calculate.free()
		_size_calculate = null

func _set_data_source(ds):
	data_source = ds
	_queue_updating_layout = true

func _set_direction(dir):
	direction = dir
	queue_update_layout()

var override_size = Vector2()
func _process(delta):
	if override_size == Vector2():
		override_size = self.rect_size
	if expand_size_to_parent and get_parent() is Control:
		override_size = get_parent().rect_size
	if self.rect_size != override_size:
		_queue_updating_layout = true
	# update layout
	if _queue_updating_layout:
		_update_layout()
		_queue_updating = true
		_queue_updating_layout = false
	# update items
	var scroll = self.scroll_horizontal if direction == HORIZONTAL else self.scroll_vertical
	if not _queue_updating:
		_queue_updating = scroll != _last_frame_scroll
		_last_frame_scroll = scroll
	if _queue_updating:
		_update_items(scroll - _last_frame_scroll)
		_queue_updating = false
	# footer & header size
	if _footer != null and _footer.rect_size != _footer_size:
		_footer.rect_size = _footer_size
	if _header != null and _header.rect_size != _header_size:
		_header.rect_size = _header_size
	# item size
	for item in _item_node_cache:
		if item.is_inside_tree() and item.rect_size != _item_size:
			item.rect_size = _item_size

func _update_items(scroll):
	var render_count = _item_node_cache.size()
	var top_index = _get_top_line_index()
	# replace front and back elements if top item changed	
	var moved_step = top_index - _last_top_index
	_last_top_index = top_index
	if moved_step > 0:
		for i in range(moved_step):
			var front = _item_node_cache[0]
			_item_node_cache.pop_front()
			_item_node_cache.push_back(front)
	elif moved_step < 0:
		for i in range(abs(moved_step)):
			var back = _item_node_cache[-1]
			_item_node_cache.pop_back()
			_item_node_cache.push_front(back)
	# update item data if necessury
	for i in range(render_count):
		var index = top_index + i
		var node = _item_node_cache[i]
		node.rect_position = _get_node_pos_by_index(index)
		if index < data_source.size() and index >= 0:
			var data = data_source[index]
			if node.data != data:
				node.data = data
			if node.rect_size != _item_size:
				node.rect_size = _item_size
			node.show()
		else:
			node.hide()
	if _footer:
		if direction == VERTICAL:
			_footer.rect_position = Vector2(0, _container.rect_min_size.y - _footer_size.y)
		elif direction == HORIZONTAL:
			_footer.rect_position = Vector2(_container.rect_min_size.x - _footer_size.x, 0)
	# emit end/begin reached signal
	if moved_step != 0:
		if top_index + get_page_size() + moved_step > data_source.size():
			emit_signal("end_reached")
		elif top_index + moved_step < 0:
			emit_signal("begin_readched")
			

func _update_layout():
	_update_size()
	_alloc_cache_nodes()

func _update_size():
	# update item size and footer/header size
	if true:
		var size = Vector2()
		var target_size = override_size
		if _size_calculate != null:
			var node = _size_calculate
			size = node.rect_min_size
			if node.size_flags_horizontal & Control.SIZE_EXPAND:
				size.x = max(target_size.x, size.x)
			if node.size_flags_vertical & Control.SIZE_EXPAND:
				size.y = max(target_size.y, size.y)
			# printt(node.size_flags_horizontal, node.size_flags_vertical, node.rect_min_size, target_size, size)
		if self._header:
			_header_size = _header.rect_min_size
			if _header.size_flags_horizontal & Control.SIZE_EXPAND:
				_header_size.x = max(target_size.x, _header_size.x)
			if _header.size_flags_vertical & Control.SIZE_EXPAND:
				_header_size.y = max(target_size.y, _header_size.y)
			if _header.rect_size != _header_size:
				_header.rect_size = _header_size
		if self._footer:
			_footer_size = _footer.rect_min_size
			if _footer.size_flags_horizontal & Control.SIZE_EXPAND:
				_footer_size.x = max(target_size.x, _footer_size.x)
			if _footer.size_flags_vertical & Control.SIZE_EXPAND:
				_footer_size.y = max(target_size.y, _footer_size.y)
		self._item_size = size
	# update container size
	if typeof(data_source) in [TYPE_ARRAY]:
		var min_size = Vector2()
		var space_size = (data_source.size() - 1) * space
		if space_size < 0:
			space_size = 0
		if direction == VERTICAL:
			min_size = Vector2(_item_size.x, _item_size.y * data_source.size() + space_size)
			if _header:	min_size.y += _header_size.y
			if _footer: min_size.y += _footer_size.y
			min_size.x -= get_v_scrollbar().rect_size.x
		elif direction == HORIZONTAL:
			min_size = Vector2(_item_size.x * data_source.size() + space_size, _item_size.y)
			if _header:	min_size.x += _header_size.x
			if _footer: min_size.x += _footer_size.x
			min_size.y -= get_h_scrollbar().rect_size.y
		_container.rect_min_size = min_size
	# update rect_size
	self.rect_size = override_size

func _alloc_cache_nodes():
	var cache_size = 0
	if direction == VERTICAL:
		cache_size = round(override_size.y / (_item_size.y + space)) + CACHE_SIZE
	elif direction == HORIZONTAL:
		cache_size = round(override_size.x / (_item_size.x + space)) + CACHE_SIZE
	var cur_cache_size = _item_node_cache.size()
	if cur_cache_size < cache_size:
		_item_node_cache.resize(cache_size)
	for i in range(cache_size):
		if _item_node_cache[i] == null:
			var node = item_template.instance()
			_item_node_cache[i] = node
			_container.add_child(node)
			node.rect_size = _item_size

func _clear():
	for node in _item_node_cache:
		node.queue_free()
	_item_node_cache.clear()

func _get_top_line_index():
	var index = -1
	if data_source.size():
		if direction == VERTICAL:
			index = floor((self.scroll_vertical - _header_size.y) / (_item_size.y + space))
		elif direction == HORIZONTAL:
			index = floor((self.scroll_horizontal - _header_size.x) / (_item_size.x + space))
	if index >= data_source.size():
		index = -1
	return index

func _get_node_pos_by_index(index):
	var pos = Vector2()
	if index >= 0 and index < data_source.size():
		if direction == VERTICAL:
			pos.x = 0
			pos.y = (_item_size.y + space) * index - space
			if _header:
				pos.y += _header_size.y
		elif direction == HORIZONTAL:
			pos.y = 0
			pos.x = (_item_size.x + space) * index - space
			if _header:
				pos.x += _header_size.x
	return pos

func get_page_size():
	if direction == VERTICAL:
		return ceil(override_size.y / (_item_size.y + space))
	elif direction == HORIZONTAL:
		return ceil(override_size.x / (_item_size.x + space))
