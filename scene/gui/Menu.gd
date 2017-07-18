##################################################################################
#           Menu.gd                                                              #
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
extends Reference

const __Utils = preload("../../utils/__init__.gd")

var title = ""				# The title of the menu item
var _parent = null			# The parent menu item
var _submenus = []			# Submenus
var is_separator = false	# Is the menu is a separator
var checkable = false		# Is the menu is checkable
var icon_res = ""			# The icon resource path
var weight = 0				# The weight of the menu item

# Menu or submenu pressed event
# **Emitted when** child item pressed
# @param [item_path:String] The path of the pressed item
signal item_pressed(item_path)

func _init(p_tite, checkable = false, separator = false, weight = 0):
	self.title = p_tite
	self.checkable = checkable
	self.is_separator = separator
	self.weight = weight

# Get the full path of the menu
# @return [String] The menu path seperated with `/`
func get_path():
	var path = title
	var parent = get_parent()
	while parent != null:
		path = str(parent.title, "/", path)
		parent = parent.get_parent()
	return path

func get_pathes_contains(root=""):
	var pathes = []
	var path = title
	if not root.empty():
		path = str(root, "/", path)
	pathes.append(path)
	for sm in _submenus:
		pathes += sm.get_pathes_contains(path)
	return pathes

func clone():
	var menu = load("res://basic/menu.gd").new(title, checkable, is_separator, weight)
	menu.icon_res = icon_res
	for sm in _submenus:
		menu.add_submenu(sm.clone())
	return menu

# Get parent menu  
# @return [Menu] The parent menu instance
func get_parent():
	if _parent != null:
		return _parent
	return null

# Add child menu item
# @param [menu:Menu] The child menu item
# @return [Menu] return self
func add_submenu(menu):
	if __Utils.implements(menu, get_script()):
		menu._parent = self
		_submenus.append(menu)
	elif typeof(menu) == TYPE_STRING:
		_submenus.append(get_script().new(menu))
	sort_children()
	return self

# Remove child menu item
# @param [menu:Menu] The child menu item to remove
# @return [Menu] return self
func remove_submenu(menu):
	if menu in _submenus:
		menu._parent = null
		_submenus.erase(menu)
	return self

# Merge all of the children with another menu
# @param [menu:Menu] The menu to merge with
# @return [Menu] Return self after merged
func merge(menu):
	for m in menu._submenus:
		var cm = get_child(m.title)
		if cm != null:
			cm.merge(m)
		else:
			add_submenu(m)
	sort_children()
	return self

# Get child menu item by title
# @param [p_title:String] The title of the child menu
# @return [Menu|Nil] Return the child menu item or null if not found
func get_child(p_title):
	for m in _submenus:
		if m.title == p_title:
			return m
	return null

# Get children menu items  
# - - - - - - - - - -  
# *Returns* Array<Menu>  
func get_children():
	return self._submenus

# Get child menu item by path
# @param [path:String] The path of the child item emnu like `Open/Text File`
# @return [Menu|Nil] Return the found menu item or null if not found
func get_item(path):
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

# Create a MenuButton with children
# @return [MenuButton] The created MenuButton instance
func make_menu_button():
	var button = MenuButton.new()
	button.set_text(title)
	render_to_popup(button.get_popup())
	return button

# Create a PopupMenu with children
# @return [PopupMenu] The created PopupMenu instance
func make_popup_menu():
	var popup = PopupMenu.new()
	render_to_popup(popup)
	return popup

# Render the menu(include all of the submenu) into a PopupMenu node
# @param [popup:PopupMenu] The PopupMenu node instance
# @param [?base_path:String] The root name of the menu
func render_to_popup(popup, base_path = "$_root_$"):
	if base_path == "$_root_$":
		base_path = get_path()
	if not _submenus.empty() and popup is PopupMenu:
		popup.connect("item_pressed", self, "_on_item_pressed", [popup])
		var __menu_id = 0
		for submenu in _submenus:
			if submenu.is_separator:
				popup.add_separator()
			elif submenu._submenus.empty():
				if submenu.checkable and not submenu.icon_res.empty():
					popup.add_icon_check_item(load(submenu.icon_res), submenu.title, __menu_id)
				elif submenu.checkable:
					popup.add_check_item(submenu.title, __menu_id)
				elif not submenu.icon_res.empty():
					popup.add_icon_item(load(submenu.icon_res), submenu.title, __menu_id)
				else:
					popup.add_item(submenu.title, __menu_id)
				popup.set_item_metadata(__menu_id, str(base_path, "/", submenu.title))
			else:
				var subpop = PopupMenu.new()
				subpop.set_name(submenu.title)
				popup.add_child(subpop)
				popup.add_submenu_item(submenu.title, submenu.title)
				submenu.render_to_popup(subpop, str(base_path, "/", submenu.title))
			__menu_id += 1

func _on_item_pressed(id, popup):
	var abspath = popup.get_item_metadata(id)
	var parent = self
	while parent != null:
		var path = abspath.substr(parent.get_path().length()+1, abspath.length())
		parent.emit_signal("item_pressed", path)
		parent = parent.get_parent()

func sort_children():
	_submenus.sort_custom(self, "__sort")
	for sm in _submenus:
		sm.sort_children()
	pass

func __sort(m1, m2):
	return m1.weight < m2.weight
