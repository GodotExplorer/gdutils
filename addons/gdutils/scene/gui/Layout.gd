##################################################################################
#           Layout.gd                                                            #
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

const FIT_WIDTH = 1									    # Fit width
const FIT_HEIGHT = 1 << 1							    # Fit height
const FIT_WIDTH_HEIGHT = FIT_WIDTH | FIT_HEIGHT         # Fit both width and height

const ANCHOR_LEFT	= 1                                 # Left aligned  
const ANCHOR_RIGHT	= 1 << 1                            # Right aligned
const ANCHOR_TOP		= 1 << 2                        # Top aligned
const ANCHOR_BOTTOM	= 1 << 3                            # Bottom aligned
const ANCHOR_HORIZENTAL_CENTER = 1	<< 4				# Center horizental aligned
const ANCHOR_VERTICAL_CENTER = 1	<< 5				# Center horizental aligned
const ANCHOR_CENTER = ANCHOR_HORIZENTAL_CENTER | ANCHOR_VERTICAL_CENTER # Center aligned
const ANCHOR_TOP_LEFT = ANCHOR_LEFT | ANCHOR_TOP        # Top-left aligned

const ZERO_SIZE = Vector2(0, 0)                         # Zero 2D size
const INVALID_SIZE = Vector2(-1, -1)                    # Invalid control size

# Autolayout manage  
# Manage scale and layout for gui controls  
class AutoLayoutManager:
	var layout_configs = []                             # The control list managed with
	
	# Get the scale ratio from designed screen size  
	# return [float] the scale ration  
	static func get_scale_ratio(fit_mode = FIT_WIDTH_HEIGHT, designScreenSize  = INVALID_SIZE):
		var scale = 1.0
	
		var ds = designScreenSize
		if ds == INVALID_SIZE:
			ds = Vector2(Globals.get("display/width"), Globals.get("display/height"))
		var window_size = OS.get_window_size()
	
		if fit_mode & FIT_HEIGHT:
			scale = float(window_size.height) / float(ds.height)
		if fit_mode & FIT_WIDTH:
			var scale1 = float(window_size.width) / float(ds.width)
			if scale1 < scale:
				scale = scale1
		return scale
	
	# Add layout configuaration
	# - - - - - - - - - -  
	# *Parameters*  
	# * [config:AutoLayoutConfig] The layout configuration  
	func add_layout(config):
		for c in layout_configs:
			if c.equals(config):
				layout_configs.erase(c)
		layout_configs.append(config)
		config.control.connect("exit_tree", self, "remove_layout", [config])
	
	# Remove layout configuration    
	# - - - - - - - - - -  
	# *Parameters*  
	# * [configOrControl: AutoLayoutConfig| Control] The layout configuration or control to remove  
	func remove_layout(configOrControl):
		for c in layout_configs:
			if c.equals(configOrControl):
				layout_configs.erase(c)
				c.control.disconnect("exit_tree", self, "remove_layout")
	
	# Update all controls' layout managed
	func update():
		for layout in layout_configs:
			_process_layout(layout)
	
	# Process layuot and scale for managed controls
	func _process_layout(layout):
		if not layout.control extends Control or not layout.control.is_visible():
			return
		var scale = get_scale_ratio(layout.fit_mode)
		var margin = layout.designMargin * scale
		layout.control.set_size(layout.designSize)
		layout.control.set_scale(Vector2(scale, scale))
		var parent = layout.control.get_parent()
		if parent != null:
			var p_size = Vector2()
			if parent extends Control:
				p_size = parent.get_size()
			elif parent extends Viewport:
				p_size = parent.get_rect().size
			elif parent extends CanvasItem:
				p_size = parent.get_item_rect().size
			var size = layout.designSize * scale
			if layout.anchor & ANCHOR_LEFT:
				layout.control.set_pos(Vector2(layout.control.get_pos().x, margin.y))
			if layout.anchor & ANCHOR_TOP:
				layout.control.set_pos(Vector2(margin.x, layout.control.get_pos().y))
			if layout.anchor & ANCHOR_RIGHT:
				layout.control.set_pos(Vector2(p_size.width - size.width - margin.x, layout.control.get_pos().y))
			if layout.anchor & ANCHOR_BOTTOM:
				layout.control.set_pos(Vector2(layout.control.get_pos().x, p_size.height - size.height - margin.y))
			if layout.anchor & ANCHOR_HORIZENTAL_CENTER:
				layout.control.set_pos(Vector2(p_size.width/2.0 - size.width/2.0 + margin.x, layout.control.get_pos().y))
			if layout.anchor & ANCHOR_VERTICAL_CENTER:
				layout.control.set_pos(Vector2(layout.control.get_pos().x, p_size.height/2.0 - size.height/2.0 + margin.y))


# Lyout configuration class
class AutoLayoutConfig:
	var control = null                      # The Control instance to layout with
	var fit_mode = FIT_WIDTH                # The scale mode for the control
	var anchor = ANCHOR_CENTER              # The align mode for the control
	var designSize = INVALID_SIZE           # The designed size of the control
	var designMargin = ZERO_SIZE            # The designed margin of the control to its designed aligment

	func _init(control, fit_mode, anchor, designSize, designMargin):
		self.control = control
		self.fit_mode = fit_mode
		self.anchor = anchor
		self.designSize = designSize
		if designSize == INVALID_SIZE:
			self.designSize = Vector2(Globals.get("display/width"), Globals.get("display/height"))
		self.designMargin = designMargin
	
	# Check is same with anothor layout configuration instance
	func equals(config):
		if config extends get_script():
			return config.control == self.control
		elif config extends Control:
			return config == self.control
		return false
	