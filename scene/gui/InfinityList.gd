##################################################################################
#    InfinityList.gd                                                              #
##################################################################################
#                            This file is part of                                #
#                                GodotExplorer                                   #
#                       https://github.com/GodotExplorer                         #
##################################################################################
# Copyright (c) 2017-2018 Godot Explorer                                         #
#                                                                                #
# Permission is hereby granted, free of charge, to any person obtaining a copy   #
# of this software and associated documentation files (the "Software"), to deal#
# in the Software without restriction, including without limitation the rights   #
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      #
# copies of the Software, and to permit persons to whom the Software is          #
# furnished to do so, subject to the following conditions:                       #
#                                                                                #
# The above copyright notice and this permission notice shall be included in all #
# copies or substantial portions of the Software.                                #
#                                                                                #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR   #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  #
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  #
# SOFTWARE.                                                                      #
##################################################################################

tool
extends ScrollContainer

export(PackedScene) var item_template
export(int, 0, 1000) var space = 0
export(int, 1, 60) var CACHE_SIZE = 1

export(int, "Horizontal", "Vertical") var direction = VERTICAL
var data_source = [] setget _set_data_source

var _container = Control.new()
var _item_size = Vector2()
var _item_node_cache = []
var _queue_updating = false
var _last_frame_scroll = -1

# Queue update the visiable items of the list  
func queue_update():
	_queue_updating = true

func _init():
	_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_container)
	var size = 100
	data_source.resize(size)
	for i in range(size):
		data_source[i] = str("Item List ", i)
	self._queue_updating = true

func _ready():
	self._item_size = _calculate__item_size()
	self.data_source = data_source
	_alloc_cache_nodes()

func _exit_tree():
	for node in _item_node_cache:
		node.queue_free()
	_item_node_cache.clear()

func _calculate__item_size():
	var size = Vector2()
	if typeof(item_template) == TYPE_OBJECT and item_template is PackedScene:
		var node = item_template.instance()
		size = node.rect_min_size
		if node.size_flags_horizontal & Control.SIZE_EXPAND:
			size.x = max(self.rect_size.x, size.x)
		if node.size_flags_vertical & Control.SIZE_EXPAND:
			size.y = max(self.rect_size.y, size.y)
		# printt(node.size_flags_horizontal, node.size_flags_vertical, size)
		node.free()
	return size

func _set_data_source(ds):
	data_source = ds
	if typeof(ds) in [TYPE_ARRAY]:
		var min_size = Vector2()
		if direction == VERTICAL:
			min_size = Vector2(_item_size.x, _item_size.y * ds.size() + (ds.size() - 1) * space)
		elif direction == HORIZONTAL:
			min_size = Vector2(_item_size.x * ds.size() + (ds.size() - 1) * space, _item_size.y)
		_container.rect_min_size = min_size

func _alloc_cache_nodes():
	var cache_size = 0
	if direction == VERTICAL:
		cache_size = ceil(self.rect_size.y / (_item_size.y + space)) + CACHE_SIZE
	elif direction == HORIZONTAL:
		cache_size = ceil(self.rect_size.x / (_item_size.x + space)) + CACHE_SIZE

	var cur_cache_size = _item_node_cache.size()
	if cur_cache_size < cache_size:
		_item_node_cache.resize(cache_size)
	for i in range(cache_size):
		if _item_node_cache[i] == null:
			var node = item_template.instance()
			_item_node_cache[i] = node
			_container.add_child(node)
			node.rect_size = _item_size

func _get_top_line_index():
	var index = -1
	if data_source.size():
		if direction == VERTICAL:
			index = floor(self.scroll_vertical / (_item_size.y + space))
		elif direction == HORIZONTAL:
			index = floor(self.scroll_horizontal / (_item_size.x + space))
	if index >= data_source.size():
		index = -1
	return index

func _get_node_pos_by_index(index):
	var pos = Vector2()
	if index >= 0 and index < data_source.size():
		if direction == VERTICAL:
			pos.x = 0
			pos.y = (_item_size.y + space) * index - space
		elif direction == HORIZONTAL:
			pos.x = (_item_size.x + space) * index - space
			pos.y = 0
	return pos

func _get_page_size():
	return _item_node_cache.size()

func _process(delta):
	var scroll = self.scroll_horizontal if direction == HORIZONTAL else self.scroll_vertical
	if _queue_updating or scroll != _last_frame_scroll:
		_last_frame_scroll = scroll
		_queue_updating = false
		var render_count = _get_page_size()
		var top_index = _get_top_line_index()
		for i in range(render_count):
			var index = top_index + i
			var node = _item_node_cache[i]
			node.rect_position = _get_node_pos_by_index(index)
			if index < data_source.size():
				var data = data_source[index]
				if node.data != data:
					node.data = data
				if node.rect_size != _item_size:
					node.rect_size = _item_size
				node.show()
			else:
				node.hide()
