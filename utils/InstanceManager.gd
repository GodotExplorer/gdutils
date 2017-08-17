##################################################################################
#  InstanceManager                            									 #
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
var pool = {}
var data = {}

func put(key, value):
    data[key] = serialize_instance(value)

func get(key):
	if data.has(key):
		return data[key]
	return .get(key)

func serialize_instance(inst):
	var ret = inst
	if typeof(inst) == TYPE_OBJECT and inst.get_script() != null:
		if not self.pool.has(inst.get_instance_id()):
			var dict = inst2dict(inst)
			self.pool[inst.get_instance_id()] = dict
			for key in dict:
				dict[key] = serialize_instance(dict[key])
			self.pool[inst.get_instance_id()] = dict
		ret = str("Object:", inst.get_instance_id())
	elif typeof(inst) == TYPE_ARRAY:
		ret = []
		for ele in inst:
			ret.append(serialize_instance(ele))
	elif typeof(inst) == TYPE_DICTIONARY:
		for key in inst:
			inst[key] = serialize_instance(inst[key])
	return ret

func unserialize_instance(any, rawPool):
	var ret = any
	if typeof(any) == TYPE_REAL:
		if int(any) == any:
			ret = int(any)
	elif typeof(any) == TYPE_STRING and any.begins_with("Object:"):
		var id  = int(any.substr("Object:".length(), any.length()))
		if self.pool.has(id):
			ret = self.pool[id]
		else:
			self.pool[id] = null
			ret = unserialize_instance(rawPool[str(id)], rawPool)
			self.pool[id] = ret
	elif typeof(any) == TYPE_DICTIONARY:
		for key in any:
			var prop = any[key]
			any[key] = unserialize_instance(prop, rawPool)
		if any.has("@path") and any.has("@subpath"):
			ret = dict2inst(any)
	elif typeof(any) == TYPE_ARRAY:
		ret = []
		for ele in any:
			ret.append(unserialize_instance(ele, rawPool))
	return ret

func load(path):
	self.pool.clear()
	self.data.clear()
	var dict = json.load_json(path)
	if dict.has("Objects"):
		var poolDict = dict["Objects"]
		for id in poolDict:
			if not int(id) in self.pool:
				self.pool[int(id)] = unserialize_instance(poolDict[id], poolDict)
		if dict.has("data"):
			var dataDict = dict["data"]
			for key in dataDict:
				self.data[key] = unserialize_instance(dataDict[key], poolDict)
		return OK
	return ERR_PARSE_ERROR

func save(path):
	return json.save_json({"Objects": pool, "data": data }, path)
