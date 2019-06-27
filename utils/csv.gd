# The csv module offers a number of high-level operations on csv files

tool

# Load tabel data from a csv file  
# The CSV must be encoded with UTF8  
# All empty line will be droped  
# - - - - - - - - - -  
# *Parameters*  
# * [`path`:`String`] The file path of the csv file  
# * [`delim`:`String`] The delimiter the csv file use.  
# - - - - - - - - - -  
# *Returns* `Array<PoolStringArray>`  
# * An array contains all line of the csv data
static func load_csv(path, delim=','):
	var array = []
	var file = File.new()
	if OK == file.open(path, File.READ):
		while not file.eof_reached():
			var line = file.get_csv_line(delim)
			var empty = true
			for column in line:
				empty = column.empty() and empty
			if line.size() > 0 and not empty:
				array.append(line)
	return array

# Make dictionary from the loaded csv raw array data  
# This method will use the first row of the data as keys of other rows  
# - - - - - - - - - -  
# *Parameters*  
# * [`array`: Array] The csv data load from ``load_csv  
# - - - - - - - - - -  
# *Returns* `Array<Dictionary>`  
# * Formated rows with key as first row
static func csv2dict(array):
	var ret = []
	if typeof(array) == TYPE_ARRAY:
		var keys = []
		if array.size() > 0:
			keys = array[0]
		for i in range(1, array.size()):
			var line = array[i]
			if typeof(line) == TYPE_STRING_ARRAY and line.size() == keys.size():
				var dictLine = {}
				for j in range(keys.size()):
					var key = keys[j]
					dictLine[key] = line[j]
				ret.append(dictLine)
	return ret
