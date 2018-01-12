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

# The window of the game  
# This class act a manager of the game window  

# The size property of the game window
var size = OS.get_window_size() setget set_window_size, get_window_size

# The title property of the window
var title = "" setget set_window_title, get_window_title

# The position property of the window
var position = Vector2(0, 0) setget set_window_position, get_window_position

func _init(title = "", size = OS.get_window_size()):
	self.title = title
	self.size = size
	OS.set_window_position((OS.get_screen_size() - size) / 2.0)

func set_window_size(size):
	if typeof(size) == TYPE_VECTOR2:
		OS.set_window_size(size)

func get_window_size():
	return OS.get_window_size()

func set_window_title(text):
	title = str(text)
	OS.set_window_title(title)

func get_window_title():
	return title

func set_window_position(pos):
	if typeof(pos) == TYPE_VECTOR2:
		OS.set_window_position(pos)

func get_window_position():
	return OS.get_window_position()
