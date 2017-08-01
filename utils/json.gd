##################################################################################
#    json.gd                                                              #
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

# Load json file instance  
# - - - - - - - - - -  
# *Parameters*  
# * [`json_path`:`String`] The file path of the json file  
# - - - - - - - - - -  
# *Returns* `Variant`  
# * A `Dictionary` instance for most situation
static func load_json(json_path):
	var file = File.new()
	if OK == file.open(json_path, File.READ):
		return parse_json(file.get_as_text())
	return {}

# Save dictionary into json file  
# - - - - - - - - - -  
# *Parameters*  
# * [dict:Dictionary] The dictinary to save  
# * [path:String] The json file path to save as 
# - - - - - - - - - -  
# *Returns* Error  
# * Return OK if succeess
static func save_json(dict, path):
	var err = OK
	if dict == null or typeof(dict) != TYPE_DICTIONARY or path == null or typeof(path) != TYPE_STRING:
		err = ERR_INVALID_PARAMETER
	var f = File.new()
	err = f.open(path, File.WRITE)
	if OK == err:
		f.store_string(to_json(dict))
		f.close()
		return OK
	else:
		return err

# Get element value from a `Dictionary` safely  
# - - - - - - - - - -  
# *Parameters*  
# * [`ds`:`Dictionary`] The data source to query from  
# * [`key`: `Variant`] The key to query  
# * [`default`: `Variant`] The default value  
# - - - - - - - - - -  
# *Returns* `Variant`  
# * Get `key` from `ds`.  
#  The `default` will be returned if `key` doesn't in the `ds`.
static func get_element_value(ds, key, default=null):
	if typeof(ds) == TYPE_DICTIONARY and ds.has(key):
		return ds[key]
	return default

# Query multi-properties form an dictionary  
# If the dictionary has not such elements default value will returned  
# - - - - - - - - - -  
# *Parameters*  
# * [ds:Dictionary] The data source to query from  
# * [format:Dictionary] The elements format with default value  
# - - - - - - - - - -  
# *Returns* Dictionary  
# * A dictionary with all keys in format  
# * If an elements in `format` doesn't exists in the `ds` the default value will be put into the result
static func get_elements(ds, format= {}):
	if typeof(ds) == TYPE_DICTIONARY and typeof(ds) == TYPE_DICTIONARY:
		var res = {}
		for key in format:
			res[key] = get_element_value(ds, key, format[key])
		return res
	else:
		return null

# Dulicate a dictionary  
# - - -  
# **Parameters**  
# * dict: Dictionary The dictionary to duplicate  
# - - -  
# **Returns**  
# * Dictionary The duplicated dictionary instance  
static func duplicate(dict):
	if typeof(dict) == TYPE_DICTIONARY:
		return bytes2var(var2bytes(dict))
	else:
		return dict

enum {
	MERGE_OVERRIDE,		# override exist data
	MERGE_KEEP		 	# keep exist data
}

# Merge two dictionaries into one  
# None of the input parmameters would be changed    
# - - -  
# **Parameters**  
# * src_data: Dictionary The source dictionary to merge  
# * new_data: Dictionary The new dictionary that will be merge to `src_data`  
# * strategy: `MERGE_KEEP | MERGE_OVERRIDE` The merge strategy for both two dictionary have save key
# 	* MERGE_KEEP : Keep values in `src_data`  
# 	* MERGE_OVERRIDE : Use values in `new_data`  
# - - -  
# **Returns**  
# * Dictionary The new merged dictionary   
static func merge(src_data, new_data, strategy = MERGE_OVERRIDE):
	if typeof(src_data) == TYPE_DICTIONARY and typeof(new_data) == TYPE_DICTIONARY:
		var ret = bytes2var(var2bytes(src_data))
		for key in new_data:
			if not ret.has(key) or strategy == MERGE_OVERRIDE:
				ret[key] = new_data[key]
		return ret
	else:
		return src_data
