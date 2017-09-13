##################################################################################
#  InstanceManager.gd                            								 #
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
const json = preload('json.gd')
var pool   = {}
var data   = {}

# Put data for saving  
# Note: The key is converted into String so please make it as simple as possiable  
# - - -  
# **Parameters**  
# * p_key: Variant The key is string value expected  
# * value: Variant The data to save with  
func put(p_key, value):
	data[str(p_key)] = _serialize(value)

# Get loaded data by a key  
# - - -  
# **Parameters**  
# * p_key: Variant The key of the data was saved  
# - - -  
# **Returns**  
# * Variant
func get(p_key):
	var key = str(p_key)
	if data.has(key):
		return data[key]
	return .get(key)

# Load the saved json file  
func load(path):
	return parse_serialized_dict(json.load_json(path))

# Save all data into json
func save(path):
	return json.save_json(serialize_to_dict(), path)

# Get a dictionary that contains all serialized instances
func serialize_to_dict():
	return {"Objects": pool, "data": data }

# parse intances from serialized dictionary
func parse_serialized_dict(dict):
	self.pool.clear()
	self.data.clear()
	if dict.has("Objects"):
		# Step1: unserialize all the objects into the poll
		# 	Some of the objects after this step may not be completely unserialized
		#   as they are circle referenced
		var poolDict = dict["Objects"]
		for id in poolDict:
			id = int(id)
			self.pool[id] = _unserialize(poolDict[str(id)], poolDict)
		# Step2: To resovle all objects that is not comletely unserialized in the poll
		#	After step1 all object should be able to referenced to now
		for id in self.pool:
			_setup_references(self.pool[id])
		# Step3: Unserailize the data user saved
		if dict.has("data"):
			var dataDict = dict["data"]
			for key in dataDict:
				self.data[key] = _unserialize(dataDict[key], poolDict)
		return OK
	return ERR_PARSE_ERROR

# Deep clone a script instance, a dictionary or an array
# - - -  
# **Parameters**  
# * inst: <Dictionary|GDInstance|Array> The data to copy from
# - - -  
# **Returns** 
# The same structured data cloned from inst
func deep_clone_instance(inst):
	if false:# For debug usage
		var im = get_script().new()
		im.put("o", inst)
		im.save("res://o.json")
		im = get_script().new()
		im.load("res://o.json")
		return im.get("o")
	var im = get_script().new()
	im.put("o", inst)
	var im2 = get_script().new()
	if OK == im2.parse_serialized_dict(parse_json(to_json(im.serialize_to_dict()))):
		return im2.get("o")
	return null

##################################################
# private methods
#################################################

func _serialize(inst):
	var ret = inst
	if typeof(inst) == TYPE_OBJECT and inst.get_script() != null:
		if not self.pool.has(inst.get_instance_id()):
			var dict = inst2dict(inst)
			self.pool[inst.get_instance_id()] = dict
			for key in dict:
				dict[key] = _serialize(dict[key])
		ret = str("Object:", inst.get_instance_id())
	elif typeof(inst) == TYPE_ARRAY:
		ret = []
		for ele in inst:
			ret.append(_serialize(ele))
	elif typeof(inst) == TYPE_DICTIONARY:
		ret = {}
		for key in inst:
			ret[key] = _serialize(inst[key])
	return ret

func _unserialize(any, rawPool):
	var ret = any
	if typeof(any) == TYPE_REAL:
		if int(any) == any:
			ret = int(any)
	elif typeof(any) == TYPE_STRING and any.begins_with("Object:"):
		var id  = int(any.substr("Object:".length(), any.length()))
		if self.pool.has(id):
			ret = self.pool[id]
		else:
			self.pool[id] = any
	elif typeof(any) == TYPE_DICTIONARY:
		for key in any:
			var prop = any[key]
			any[key] = _unserialize(prop, rawPool)
		if any.has("@path") and any.has("@subpath"):
			ret = dict2inst(any)
	elif typeof(any) == TYPE_ARRAY:
		ret = []
		for ele in any:
			ret.append(_unserialize(ele, rawPool))
	return ret

func _setup_references(inst):
	var ret = inst
	if typeof(inst) == TYPE_OBJECT:
		for propDesc in inst.get_property_list():
			var prop = inst.get(propDesc.name)
			if typeof(prop) in [TYPE_STRING, TYPE_ARRAY, TYPE_DICTIONARY]:
				inst.set(propDesc.name, _setup_references(prop))
	elif typeof(inst) == TYPE_STRING and inst.begins_with("Object:"):
		var id = int(inst.substr("Object:".length(), inst.length()))
		if self.pool.has(id):
			ret = self.pool[id]
	elif typeof(inst) == TYPE_ARRAY:
		ret = []
		for ele in inst:
			ret.append(_setup_references(ele))
	elif typeof(inst) == TYPE_DICTIONARY:
		ret = {}
		for key in inst:
			ret[key] = _setup_references(inst[key])
	return ret
