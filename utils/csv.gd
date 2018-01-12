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



