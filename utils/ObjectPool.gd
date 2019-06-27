# A simple object pool to cache and reuse objects

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
