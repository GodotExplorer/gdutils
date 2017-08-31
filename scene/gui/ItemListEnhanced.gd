##################################################################################
#    ItemListEnhanced.gd                                                         #
##################################################################################
#                            This file is part of                                #
#                                GodotExplorer                                   #
#                       https://github.com/GodotExplorer                         #
##################################################################################
# Copyright (c) 2017 Godot Explorer                                              #
#                                                                                #
# Permission is hereby granted, free of charge, to any person obtaining a copy   #
# of this software and associated documentation files (the "Software"), to deal  #
# in the Software without restriction, including without limitation the rights   #
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      #
# copies of the Software, and to permit persons to whom the Software is          #
# furnished to do so, subject to the following conditions:                       #
#                                                                                #
# The above copyright notice and this permission notice shall be included in all #
# copies or substantial portions of the Software.                                #
#                                                                                #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  #
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  #
# SOFTWARE.                                                                      #
##################################################################################

tool
extends ItemList

signal double_clicked()
signal mouse_right_clicked()

# ListItemProvider  
# The provider of the item list it decides how the data is shown in the list
var provider = ListItemProvider.new() setget _set_provider
func _set_provider(p):
	# FIXME: GDScript BUG : https://github.com/godotengine/godot/issues/10304
	if typeof(p) == TYPE_OBJECT :#and p is ListItemProvider:
		provider = p
		update_list()

# Arrary<Variant>  
# The item data source of the list
var data_source = [] setget _set_data_source
func _set_data_source(arr):
	data_source = arr
	update_list()

# Variant  
# The filter to decide is item in the `data_source` should be shown in the list
var filter = null setget _set_filter
func _set_filter(f):
	filter = f
	update_list()


# Emited while wating action trigged with the list view
signal on_action_pressed(action)

# Event gui actions to watch with  
# Type: Array<String|InputEvent>  actions to watch
var watching_actions = []

# Force update the item list  
# This action will clear and re-order the items
func update_list():
	clear()
	if typeof(data_source) == TYPE_ARRAY:
		var data_for_show = data_source
		if provider.sort_required(data_source):
			data_for_show = []
			for data in data_source:
				data_for_show.append(data)
			data_for_show.sort_custom(provider, 'sort')

		var index = 0
		for data in data_for_show:
			if not provider.item_fit_filter(data, filter):
				continue
			var text = provider.get_item_text(data)
			if typeof(text) == TYPE_STRING:
				add_item(text)
				set_item_metadata(index, data)
				set_item_icon(index, provider.get_item_icon(data))
				var color = provider.get_item_background_color(data)
				if typeof(color) == TYPE_COLOR:
					set_item_custom_bg_color(index, color)
				index += 1

# Update target item of in the list
func update_item(p_item):
	for id in range(get_item_count()):
		if p_item == get_item_metadata(id):
			set_item_text(id, provider.get_item_text(p_item))
			set_item_custom_bg_color(id, provider.get_item_background_color(p_item))
			set_item_icon(id, provider.get_item_icon(p_item))
			break

# Select items, the items selected before will be unselected  
# items: Array<Variant> items to select
func selecte_items(p_items):
	if typeof(p_items) != TYPE_ARRAY:
		p_items = [p_items]
	for id in get_selected_items():
		unselect(id)
	var single = p_items.size() > 1
	var selected = false
	for item in p_items:
		for i in range(get_item_count()):
			if get_item_metadata(i) == item:
				select(i, single)
				selected = true
				if single:
					break
		if single and selected:
			break

# Get selected item data in an array
func get_selected_item_list():
	var _items = []
	for idx in get_selected_items():
		_items.append(get_item_metadata(idx))
	return _items

func _gui_input(event):
	if event is InputEventMouseButton:
		if get_selected_items().size() > 0:
			return
		if event.button_index == BUTTON_RIGHT and not event.pressed:
			emit_signal("mouse_right_clicked")
		elif event.doubleclick:
			emit_signal("double_clicked")
	if event.is_pressed():
		for action in watching_actions:
			if typeof(action) == TYPE_STRING:
				if event.is_action(action):
					emit_signal("on_action_pressed", action)
					break
			elif typeof(action) == TYPE_OBJECT and action is InputEvent:
				if event.action_match(action):
					emit_signal("on_action_pressed", action)
					break

# The provider class for ItemList  
# The provider decide how the data source is shown in the item list
class ListItemProvider:
	# If your list need sort items return `true` here then the list wil try to
	# sort items with `sort` while update
	func sort_required(p_data_source):
		return false
	
	# The sort function to be used for item sorting  
	#
	# -------------  
	# @parameters  
	#  * p_item1  
	#  * p_item2  
	#  The item data to sort with  
	#
	# -------------
	# Return true if `p_item1` needs to be shown before `p_item2`
	func sort(p_item1, p_item2):
		return true
	
	# Check if the item should be shown with the given filter from the list
	# 
	# -------------  
	# @parameters  
	#  * p_item  
	#  * p_filter  
	#
	# -------------
	# Return true if `p_item1` needs to be shown before `p_item2`
	func item_fit_filter(p_item, p_filter):
		return true
	
	func get_item_text(p_item):
		return str(p_item)
	
	func get_item_icon(p_item):
		return null

	func get_item_background_color(p_item):
		return Color(0, 0, 0, 0)
