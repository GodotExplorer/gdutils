tool
extends ItemList

signal double_clicked()
signal mouse_right_clicked()
signal selection_changed(selected_items)

const ACCEPT_DS_TYPES = [
	TYPE_ARRAY,
	TYPE_INT_ARRAY,
	TYPE_REAL_ARRAY,
	TYPE_COLOR_ARRAY,
	TYPE_STRING_ARRAY,
	TYPE_VECTOR2_ARRAY,
	TYPE_VECTOR3_ARRAY
]

func _init():
	connect("item_selected", self, "__on_select_changed")
	connect("multi_selected", self, "__on_select_changed")
	connect("nothing_selected", self, "__on_select_changed")

# ListItemProvider  
# The provider of the item list it decides how the data is shown in the list
var provider = ListItemProvider.new() setget _set_provider
func _set_provider(p):
	if typeof(p) == TYPE_OBJECT:# and p is ListItemProvider:# FIXME: BUG of GDScript?
		provider = p
		update_list()

var menu_handler = MenuActionHandler.new() setget _set_menu_handler
var _popupmenu = null
func _set_menu_handler(h):
	menu_handler = h
	if _popupmenu != null:
		_popupmenu.queue_free()
		remove_child(_popupmenu)
		_popupmenu = null
	if typeof(h) == TYPE_OBJECT:# and h is MenuActionHandler:# FIXME: BUG of GDScript?
		_popupmenu = h.create_popupmenu()
		if _popupmenu != null:
			_popupmenu.connect("id_pressed", self, "_on_menu_id_pressed")
			add_child(_popupmenu)

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
	if typeof(data_source) in ACCEPT_DS_TYPES:
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
	if not typeof(p_items) in ACCEPT_DS_TYPES:
		p_items = [p_items]
	for id in get_selected_items():
		unselect(id)
	var single = p_items.size() == 1
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
	# Mouse button actions
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and not event.pressed:
			if _popupmenu != null:
				_popupmenu.set_global_position(get_global_mouse_position())
				var selectedItems = get_selected_item_list()
				for i in range(_popupmenu.get_item_count()):
					var id = _popupmenu.get_item_id(i)
					_popupmenu.set_item_disabled(i, not menu_handler.item_enabled(id, selectedItems))
				_popupmenu.popup()
			emit_signal("mouse_right_clicked")
		elif event.doubleclick:
			emit_signal("double_clicked")
	# Watching actions
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
	# Popupmenu shortcuts
	if event.is_pressed() and _popupmenu != null:
		var selectedItems = get_selected_item_list()
		for i in range(_popupmenu.get_item_count()):
			var id = _popupmenu.get_item_id(i)
			var shortcut = _popupmenu.get_item_shortcut(i)
			if shortcut != null and shortcut is ShortCut and event.action_match(shortcut.shortcut):
				if not _popupmenu.is_item_disabled(i):
					menu_handler.id_pressed(id, selectedItems)

func _on_menu_id_pressed(id):
	menu_handler.id_pressed(id, get_selected_item_list())

func __on_select_changed(useless=null, useless2=null):
	emit_signal("selection_changed", get_selected_item_list())

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

# Right mouse button popup menu handler
class MenuActionHandler:
	# Create the popup menu control for this list view
	func create_popupmenu():
		return null
	# Check the item with id is enabled for selected items
	func item_enabled(id, selectedItems):
		return true
	# This method is call when the menu item is pressed or its shortcut is pressed
	func id_pressed(id, selectedItems):
		pass
