##################################################################################
#    path.gd                                                                     #
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

# Return a list containing the names of the files in the directory.  
# It does not include the special entries '.' and '..' even if they are present in the directory.
# - - - - - - - - - -  
# *Parameters*  
# * [path:String] The directory to search with  
# - - - - - - - - - -  
# *Returns* Array<String>  
# * The list containing the names of the files in the directory
# * Return `[]` if failed to search the target directory
func list_dir(path):
	var pathes = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var path = dir.get_next()
		while not path.empty():
			if not path in ['.', '..']:
				pathes.append(path)
			path = dir.get_next()
		dir.list_dir_end()
	return pathes

#  Get file pathes in a list under target folder   
# - - - - - - - - - -  
# *Parameters*  
# * [path:String] The folder to search from  
# * [with_dirs:bool = false] Includes directories  
# * [recurse:String = false] Search sub-folders recursely  
# - - - - - - - - - -  
# *Returns* Array<String>  
# * File pathes in an array
static func list_files(path, with_dirs=false,recurse=false):
	var files = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while not file_name.empty():
			if dir.current_is_dir() and not (file_name in [".", "..", "./"]):
				if recurse:
					var childfiles = get_files_in_dir(str(path, "/", file_name), with_dirs, recurse)
					for f in childfiles:
						files.append(f)
			if not (file_name in [".", ".."]):
				var rpath = path
				if rpath.ends_with("/"):
					pass
				elif rpath == ".":
					rpath = ""
				else:
					rpath += "/"
				if not with_dirs and dir.current_is_dir():
					pass
				else:
					rpath = str(rpath, file_name).replace("/./", "/")
					files.append(rpath)
			file_name = dir.get_next()
	return files