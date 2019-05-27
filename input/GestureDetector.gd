##################################################################################
#                        Tool generated DO NOT modify                            #
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
extends Node

enum SlideDetectMethod { DISTANCE, SPEED }
export(SlideDetectMethod) var silde_detect_method = SlideDetectMethod.SPEED
export var slide_distance = 100
export var slide_speed = 600

enum SlideGesture {
	SLIDE_NONE,
	SLIDE_UP,
	SLIDE_DOWN,
	SLIDE_LEFT,
	SLIDE_RIGHT
}

signal slide(dir)

var _touch_down = false
var _down_pos = Vector2()
var _accept_slide = false

func _input(event: InputEvent):
	if event is InputEventScreenTouch:
		_touch_down = event.pressed
		if _touch_down:
			_down_pos = event.position
			_accept_slide = true
		else:
			_accept_slide = false
	if _touch_down and event is InputEventMouseMotion:
		if _accept_slide:
			var dir = SlideGesture.SLIDE_NONE
			# detect slide by speed
			if silde_detect_method == SlideDetectMethod.SPEED:
				var speed = event.speed
				var speed_abs = speed.abs()
				var max_side_speed = max(speed_abs.x, speed_abs.y);
				if max_side_speed >= slide_speed:
					var side_speed = speed.x
					if speed_abs.y == max_side_speed:
						side_speed = speed.y
						dir = SlideGesture.SLIDE_DOWN if side_speed > 0 else SlideGesture.SLIDE_UP
					else:
						dir = SlideGesture.SLIDE_RIGHT if side_speed > 0 else SlideGesture.SLIDE_LEFT
			# detect slide by move distance
			elif silde_detect_method == SlideDetectMethod.DISTANCE:
				var delta = event.position - _down_pos
				var delta_abs = delta.abs()
				var max_side = max(delta_abs.x, delta_abs.y)
				if max_side > slide_distance:
					if max_side == delta_abs.x:
						dir = SlideGesture.SLIDE_RIGHT if delta.x > 0 else SlideGesture.SLIDE_LEFT
					else:
						dir = SlideGesture.SLIDE_DOWN if delta.y > 0 else SlideGesture.SLIDE_UP
			if dir != SlideGesture.SLIDE_NONE:
				self._accept_slide = false;
				self.emit_signal("slide", dir);
				