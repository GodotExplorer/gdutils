##################################################################################
#    ScrollableTabContainer.gd                                                              #
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
extends Control
export var slide_speed = 1000.0
export var expand_pages = false
signal on_side_page_finished(page)

var tween = Tween.new()
var pages = []
var content_size = Vector2()
var _sliding = false
var page_container = Control.new()
var _protected_nodes = []

func _init():
	tween.name = 'Tween'
	tween.connect('tween_completed', self, 'on_tween_completed')
	add_child(tween)
	page_container.name = 'pages'
	add_child(page_container)
	_protected_nodes = [
		tween,
		page_container
	]

func clear():
	pages.clear()
	for page in page_container.get_children():
		page_container.remove_child(page)

func add_page(name, control):
	if not control in pages:
		pages.append(control)
		control.name = name
		control.rect_position = Vector2(content_size.x, 0)
		var size = control.rect_size
		self.content_size.x += size.x
		self.content_size.y = max(size.y, content_size.y)

var current_page = '' setget show_page
func show_page(name):
	current_page = name
	var tar_pos = null
	for page in pages:
		if page.get_parent() == null:
			page_container.add_child(page)
		if page.name == name:
			tar_pos = Vector2(-page.rect_position.x, 0)
	if tar_pos != null:
		_sliding = true
		var init_val = page_container.rect_position
		if init_val != tar_pos:
			var duration = (init_val - tar_pos).length() / slide_speed
			tween.interpolate_property(page_container, 'rect_position', init_val, tar_pos, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.start()
		else:
			on_tween_completed(self, 'rect_position')

func get_page(name):
	for p in pages:
		if p.name == name:
			return p
	return null

func on_tween_completed(obj, key):
	_sliding = false
	for page in pages:
		var global_rect = Rect2(page.rect_global_position, page.rect_size)
		# FIXME: 引擎BUG， 获取到错误的控件位置
		# var self_rect = Rect2(self.rect_global_position, self.rect_size)
		# if not global_rect.intersects(self_rect):
		if page.name != current_page:
			if page.get_parent() == page_container:
				page_container.remove_child(page)
	emit_signal("on_side_page_finished", current_page)


func _ready():
	if not Engine.editor_hint:
		for n in get_children():
			if not (n in _protected_nodes) and n is Control:
				remove_child(n)
				add_page(n.name, n)
				if current_page.empty():
					current_page = n.name
		if not current_page.empty():
			self.current_page = current_page

func _process(delta):
	if expand_pages:
		for page in pages:
			if page.rect_size != self.rect_size:
				page.rect_size = self.rect_size
