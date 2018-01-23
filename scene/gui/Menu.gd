##################################################################################
#                            This file is part of                                #
#                                GodotExplorer                                   #
#                       https://github.com/GodotExplorer                         #
##################################################################################
# Copyright (c) 2017-2018 Godot Explorer                                         #
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
extends Reference

# Menu type
enum {
	NORMAL,
	CHECHABLE,
	SEPARATOR
}

var type		 = NORMAL	# Type of the menu item
var icon 		 = null		# The icon texture
var title 		 = ""		# The title text of the menu item
var disabled	 = false	# The item is disabled or enabled
var children	 = []		# Array<Menu> Submenus
var parent_ref 	 = null		# Weakref<Menu> The parent menu item
signal item_pressed(item)	# emitted on menu item is pressed

func _init(p_title = ""):
	title = p_title

# Get child menu item by title
# @param [p_title:String] The title of the child menu
# @return [Menu|Nil] Return the child menu item or null if not found
func get_child(p_title):
	for m in children:
		if m.title == p_title:
			return m
	return null

# Get children menu items  
# - - - - - - - - - -  
# *Returns* Array<Menu>  
func get_children():
	return self.children

# Get parent menu
# - - - - - - - - - -  
# *Returns* Menu  
# The parent menu instance
func get_parent():
	if parent_ref != null:
		return parent_ref.get_ref()
	return null

# Reset the parent menu item  
# - - - - - - - - - -  
# *Parameters*  
# * [new_parent: Menu] The new parent menu item  
# - - - - - - - - - -  
# *Returns* Menu  
# * Return self menu after reparent
func reparent(new_parent):
	var parent = get_parent()
	if parent == new_parent:
		return
	if parent != null:
		if self in parent.children:
			parent.children.erase(self)
	if new_parent != null:
		new_parent.children.append(self)
		parent_ref = weakref(new_parent)
	else:
		parent_ref = null
	return self

# Remove child menu item
# @param [menu:Menu] The child menu item to remove
# - - - - - - - - - -  
# *Returns* Menu  
# * Return self menu item
func remove_child(p_menu):
	p_menu.reparent(null)
	return self

# Add child menu item
# @param [menu:Menu] The child menu item  
# - - - - - - - - - -  
# *Returns* Menu  
# * Return self menu item
func add_child(p_menu):
	p_menu.reparent(self)
	return self

# Add a seperator menu item
# - - - - - - - - - -  
# *Returns* Menu  
# * Return self menu item
func add_separator():
	var item = get_script().new()
	item.type = SEPARATOR
	add_child(item)
	return self

# Create a sub-menu item  
# - - - - - - - - - -  
# *Parameters*  
# * [p_type: MenuType] The type of the menu item  
# * [p_title: String] The menu item title  
# - - - - - - - - - -  
# *Returns* Menu  
# * Return the created menu item
func create_item(p_title=""):
	var item  = get_script().new(p_title)
	add_child(item)
	return item

# Get the full path of the menu item
# @return [String] The menu path is seperated with `/`
func get_path():
	var path = title
	var parent = get_parent()
	while parent != null:
		path = str(parent.title, "/", path)
		parent = parent.get_parent()
	return path

# Clone the menu item include its submenu items  
# - - - - - - - - - -  
# *Returns* Variant  
# * Return document
func clone():
	var menu        = get_script().new()
	menu.type       = type
	menu.icon       = icon
	menu.title      = title
	menu.disabled   = disabled
	menu.parent_ref = parent_ref
	for item in children:
		menu.add_submenu(item.clone())
	return menu

# Find child menu item by path  
# - - - - - - - - - -  
# @param [path:String] The path of the child item emnu like `Open/Text File`  
# - - - - - - - - - -  
# @return [Menu|Nil] Return the found menu item or null if not found  
func find_item(path):
	if typeof(path) == TYPE_STRING and not path.empty():
		var titles = path.split("/")
		var menu = self
		for t in titles:
			menu = menu.get_child(t)
			if menu == null:
				return null
		if menu != self and menu.title == titles[-1]:
			return menu
	return null

# Render the menu(include all of the submenu) into a MenuButton control  
func render_to_menu_button(p_button):
	if typeof(p_button) == TYPE_OBJECT and p_button is MenuButton:
		p_button.set_text(title)
		render_to_popup(p_button.get_popup())

# Render the menu(include all of the submenu) into a PopupMenu node
# @param [popup:PopupMenu] The PopupMenu node instance
var popups = []
func render_to_popup(popup):
	if not children.empty() and typeof(popup) == TYPE_OBJECT and popup is PopupMenu:
		if not popup.is_connected("id_pressed", self, "_on_item_pressed"):
			popup.connect("id_pressed", self, "_on_item_pressed", [popup])
			popups.append(popup)
		var idx = 0
		for item in children:
			if item.type == SEPARATOR:
				popup.add_separator()
			elif item.children.empty():
				if item.type == CHECHABLE:
					if item.icon != null:
						popup.add_icon_check_item(item.icon, item.title, idx)
					else:
						popup.add_check_item(item.title, idx)
				elif item.icon != null:
					popup.add_icon_item(item.icon, item.title, idx)
				else:
					popup.add_item(item.title, idx)
			else:
				var subpop = PopupMenu.new()
				subpop.set_name(item.title)
				popup.add_child(subpop)
				popup.add_submenu_item(item.title, item.title, idx)
				item.render_to_popup(subpop)
			popup.set_item_metadata(idx, item)
			idx += 1

# Load items form dictionary  
# - - - - - - - - - -  
# *Parameters*  
# * [dict: Dictionary] Menu configuration data
# ```gdscript
# menu.parse_dictionary({
# 	"title": "Export",
# 	"icon": "res://icon.png"
# 	"items": [
# 	  { "title": "PNG File", "disabled": true},
# 	  { "type": "separator"}
# 	  { "title": "JPG File", "type": "checkable"}
# 	]
# })
# ```
func parse_dictionary(dict):
	self.title = str(dict.title) if dict.has('title') else self.title
	self.disabled = bool(dict.disabled) if dict.has('disabled') else false
	self.icon = load(str(dict.icon)) if dict.has('icon') else null
	if dict.has('type') and typeof(dict.type) == TYPE_STRING:
		if dict.type.to_lower() == 'separator':
			self.type = SEPARATOR
		elif dict.type.to_lower() in ['checkable', 'check', 'checkbox']:
			self.type = CHECHABLE
	if dict.has('items') and typeof(dict.items) == TYPE_ARRAY:
		for item in dict.items:
			if typeof(item) == TYPE_DICTIONARY:
				var m = get_script().new()
				m.parse_dictionary(item)
				add_child(m)

func _on_item_pressed(idx, popup):
	var menu   = popup.get_item_metadata(idx)
	var parent = self
	while parent != null:
		parent.emit_signal("item_pressed", menu)
		parent = parent.get_parent()
