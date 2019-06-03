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
var objects = []
var _using_objects = {}

# Pool size
var size = 0 setget resize, get_size
func get_size() -> int:
	return objects.size()

# Using object count in the pool
var using_count setget , get_using_count
func get_using_count() -> int:
	var count = 0
	for i in range(objects.size()):
		if _using_objects[i]:
			count += 1
	return count

# Set the pool size
func resize(v: int):
	if v >= 0:
		var last_size = objects.size()
		if v > objects.size():
			objects.resize(v)
			for i in range(last_size, v):
				objects[i] = create_object()
				_using_objects[i] = false
		elif v < last_size:
			for i in range(v, last_size):
				var obj = objects[i]
				destroy_object(obj)
				_using_objects[i] = false
			objects.resize(v)

# Get an object from the pool
func get_object() -> Object:
	for i in range(objects.size()):
		if not _using_objects[i]:
			_using_objects[i] = true
			return objects[i]
	var idx = objects.size()
	resize(idx + 1)
	_using_objects[idx] = true
	return objects[idx]

# Release an object to the pool  
# The object must be returned from `get_object` method 
func release(p_object: Object):
	var idx = objects.find(p_object)
	if idx != -1:
		if _using_objects[idx]:
			release_object(p_object)
			_using_objects[idx] = false

# Release all of the objects in the pool  
# Make all of the objects is usable  
# This method won't destroy objects  
func clear():
	for i in range(objects.size()):
		if _using_objects[i]:
			release_object(objects[i])
			_using_objects[i] = false

# Destroy all of the objects in the pool
func destroy():
	clear()
	for obj in objects:
		destroy_object(obj)
	resize(0)
	_using_objects = {}

# The method to override to create object for the pool
func create_object() -> Object:
	return null

# Call on an object is release(return back) to the pool
func release_object(p_object: Object):
	pass

# The method to override to destroy object for the pool
func destroy_object(p_object: Object):
	if not p_object is Reference:
		p_object.free()
