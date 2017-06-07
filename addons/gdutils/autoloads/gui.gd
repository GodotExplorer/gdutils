##################################################################################
#           gui.gd                                                               #
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
extends Node

const Layout = preload("../scene/gui/Layout.gd")
const Window = preload("../scene/gui/Window.gd")

const DESIGN_SCREEN_SIZE = Layout.INVALID_SIZE          	# Design screen size as constant
const UPDATE_DURATION_MS = 10						    # UI update duration in milliseconds

var shouldUpdate = true                                 # UI needs update in next frame
var window = null                                       # The game window instance

var _layoutManager = null                               # The layout manager instance
var _frameUpdateAt = 0                                  # The gui last updated time

func _init():
	DESIGN_SCREEN_SIZE = Vector2(Globals.get("display/width"), Globals.get("display/height"))
	window = Window.new()
	_layoutManager = Layout.AutoLayoutManager.new()
	set_process(true)

func _process(delta):
	var curTime = OS.get_ticks_msec()
	if curTime - _frameUpdateAt >= UPDATE_DURATION_MS:
		_frameUpdateAt = curTime
		shouldUpdate = true
	else:
		shouldUpdate = false
	if shouldUpdate:
		_layoutManager.update()

# Register a control to auto-layout  manager 
# The registed control will be scaled and relayouted when the gdutil autoload instance's gui system update
# - - - - - - - - - -  
# *Parameters*  
# * `control`: Control The control node to layout with  
# * `anchor`: int The alignment mode of the control which is a value of constant begins with `lib.scene.gui.Layout.ANCHOR_`  
# * `fit_mode`: int The scale mode of the control which is a value of constant begins with `lib.scene.gui.Layout.FIT_`  
# * `designSize`: Vector2 The design size of the control means the size of the control in design screen  
# * `designMargin`: Vector2 The design margin of the control with it design `anchor` alignment in the design screen size  
#   * `x` : The horizental margin value
#   * `y` : The vertical margin value  
# - - - - - - - - - -  
# *Returns* bool  
# * Return Is the control node is registered
func layout(control, anchor=Layout.ANCHOR_CENTER, fit_mode = Layout.FIT_WIDTH_HEIGHT, designSize = Layout.INVALID_SIZE, designMargin = Layout.ZERO_SIZE):
	if not control extends Control:
		return false
	var ds = designSize
	if ds == Layout.INVALID_SIZE:
		ds = DESIGN_SCREEN_SIZE
	_layoutManager.add_layout(Layout.AutoLayoutConfig.new(control, fit_mode, anchor, ds, designMargin))
	return true