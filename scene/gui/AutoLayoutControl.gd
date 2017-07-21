##################################################################################
#    AutoLayoutControl.gd                                                              #
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
extends Control

const Layout = preload("Layout.gd")

# The scale mode for the control
export(int, FLAGS, "Width", "Height") var fit_mode = Layout.FIT_WIDTH_HEIGHT
# The align mode for the control
export(int, FLAGS, "Left", "Right", "Top", "Bottom", "Horizental Center", "Vertical Center") var anchor_mode = Layout.ANCHOR_CENTER			
# The designed size of the control
export var design_size = Layout.INVALID_SIZE
# The designed margin of the control to its designed aligment
export var designMargin = Layout.ZERO_SIZE
# UI update duration in milliseconds
export var UPDATE_DURATION_MS = 10
# UI needs update in next frame
var shouldUpdate = true

# The layout manager instance            
var _layoutManager = null               
# The gui last updated time
var _frameUpdateAt = 0

func _init():
	_layoutManager = Layout.AutoLayoutManager.new()

func _process(delta):
	var curTime = OS.get_ticks_msec()
	if curTime - _frameUpdateAt >= UPDATE_DURATION_MS:
		_frameUpdateAt = curTime
		shouldUpdate = true
	else:
		shouldUpdate = false
	if shouldUpdate:
		_layoutManager.update()

func _enter_tree():
	_layoutManager.add_layout(Layout.AutoLayoutConfig.new(self, fit_mode, anchor_mode, design_size, designMargin))
	set_process(true)

func _exit_tree():
	_layoutManager.remove_layout(self)
