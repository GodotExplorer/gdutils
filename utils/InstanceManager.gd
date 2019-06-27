# Serialize and unserialize for GDScript instances

tool
const json = preload('json.gd')

const TYPE_ATOMIC_PREFIX     = "@Atomic:"
const LEN_TYPE_ATOMIC_PREFIX = 8

const TYPE_OBJECT_PREFIX     = "@Object:"
const LEN_TYPE_OBJECT_PREFIX = 8

const TYPE_REF_PREFIX		 = "@Reference:"
const LEN_TYPE_REF_PREFIX    = 11

const MEATA_NAME_INST_UID 	 = "@InstanceID"

# Atomic types that json doesn't support
const SERIALIZED_ATOMIC_TYPES = [
	TYPE_VECTOR2,
	TYPE_RECT2,
	TYPE_VECTOR3,
	TYPE_TRANSFORM2D,
	TYPE_PLANE,
	TYPE_QUAT,
	TYPE_AABB,
	TYPE_BASIS,
	TYPE_TRANSFORM,
	TYPE_COLOR,
]

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
	_reset()
	if dict.has("Objects"):
		# Step1: unserialize all the objects into the poll
		# 	Some of the objects after this step may not be completely unserialized
		#   as they are circle referenced
		var poolDict = dict["Objects"]
		for id in poolDict:
			id = int(id)
			_parsing_instance_uid = id
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
var _parsing_instance_uid   = 0
var _max_instance_uid       = 0
var _instance_uid_map       = {}
var _uid_instance_map       = {}

func _reset():
	pool.clear()
	data.clear()
	_instance_uid_map.clear()
	_uid_instance_map.clear()
	_parsing_instance_uid = 0
	_max_instance_uid = 0

func _serialize(inst):
	var ret = inst
	if typeof(inst) in SERIALIZED_ATOMIC_TYPES:
		ret = str(TYPE_ATOMIC_PREFIX, var2str(inst))
	elif typeof(inst) == TYPE_OBJECT:
		if inst is WeakRef:
			var obj = inst.get_ref()
			ret = _serialize(obj).replace(TYPE_OBJECT_PREFIX, TYPE_REF_PREFIX) if obj != null else null
		elif inst.get_script() != null:
			var uid = 0
			var is_replace = false
			var InstID = inst.get_instance_id()
			if not _instance_uid_map.has(InstID):
				uid = _max_instance_uid
				if inst.has_meta(MEATA_NAME_INST_UID):
					uid = inst.get_meta(MEATA_NAME_INST_UID)
					if self.pool.has(uid):
						is_replace = true
						var old_inst_id = _uid_instance_map[uid]
						_instance_uid_map[old_inst_id] = _max_instance_uid
						_uid_instance_map[_max_instance_uid] = old_inst_id
						self.pool[_max_instance_uid] = self.pool[uid]
				_instance_uid_map[InstID] = uid
				_uid_instance_map[uid]    = InstID
				_max_instance_uid += 1
			else:
				uid = _instance_uid_map[InstID]
			if is_replace or (not self.pool.has(uid)):
				var dict = inst2dict(inst)
				self.pool[uid] = dict
				for key in dict:
					dict[key] = _serialize(dict[key])
			ret = str(TYPE_OBJECT_PREFIX, uid)
	elif typeof(inst) == TYPE_ARRAY:
		ret = []
		for ele in inst:
			ret.append(_serialize(ele))
	elif typeof(inst) == TYPE_DICTIONARY:
		ret = {}
		for key in inst:
			ret[_serialize(key)] = _serialize(inst[key])
	return ret

func _unserialize(any, rawPool):
	var ret = any
	if typeof(any) == TYPE_REAL:
		if int(any) == any:
			ret = int(any)
	elif typeof(any) == TYPE_STRING:
		if any.begins_with(TYPE_OBJECT_PREFIX):
			var id  = int(any.substr(LEN_TYPE_OBJECT_PREFIX, any.length()))
			if self.pool.has(id):
				ret = self.pool[id]
			else:
				self.pool[id] = any
		elif any.begins_with(TYPE_ATOMIC_PREFIX):
			var text  = any.substr(LEN_TYPE_ATOMIC_PREFIX, any.length())
			ret = str2var(text)
	elif typeof(any) == TYPE_DICTIONARY:
		for key in any:
			var prop = any[key]
			any[_unserialize(key, rawPool)] = _unserialize(prop, rawPool)
		if any.has("@path") and any.has("@subpath"):
			ret = dict2inst(any)
			if typeof(ret) == TYPE_OBJECT:
				ret.set_meta(MEATA_NAME_INST_UID, _parsing_instance_uid)
	elif typeof(any) == TYPE_ARRAY:
		ret = []
		for ele in any:
			ret.append(_unserialize(ele, rawPool))
	return ret

func _setup_references(inst):
	var ret = inst
	if typeof(inst) == TYPE_OBJECT:
		for propDesc in inst.get_property_list():
			if propDesc.usage & PROPERTY_USAGE_CATEGORY: continue
			var prop = inst.get(propDesc.name)
			if typeof(prop) in [TYPE_STRING, TYPE_ARRAY, TYPE_DICTIONARY]:
				inst.set(propDesc.name, _setup_references(prop))
	elif typeof(inst) == TYPE_STRING:
		if inst.begins_with(TYPE_OBJECT_PREFIX):
			var id = int(inst.substr(LEN_TYPE_OBJECT_PREFIX, inst.length()))
			if self.pool.has(id):
				ret = self.pool[id]
		elif inst.begins_with(TYPE_REF_PREFIX):
			var id = int(inst.substr(LEN_TYPE_REF_PREFIX, inst.length()))
			if self.pool.has(id):
				ret = weakref(self.pool[id])
	elif typeof(inst) == TYPE_ARRAY:
		ret = []
		for ele in inst:
			ret.append(_setup_references(ele))
	elif typeof(inst) == TYPE_DICTIONARY:
		ret = {}
		for key in inst:
			ret[_setup_references(key)] = _setup_references(inst[key])
	return ret
