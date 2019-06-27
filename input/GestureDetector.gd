# This Node is used to detect gestures

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
				