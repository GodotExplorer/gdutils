# This module implements some useful functions on file path.

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
static func list_dir(path):
	var pathes = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var cwd = dir.get_next()
		while not cwd.empty():
			if not cwd in ['.', '..']:
				pathes.append(cwd)
			cwd = dir.get_next()
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
					var childfiles = list_files(str(path, "/", file_name), with_dirs, recurse)
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

# Join two or more path components intelligently.  
# The return value is the concatenation of path and any members of rest parameters
# with exactly one directory separator `/` 
# *Parameters*  
# * [`p0~p9`:String] The paths
# - - - - - - - - - -  
# *Returns* String
# * The returen path is `normalized`
static func join(p0, p1, p2='', p3='', p4='', p5='', p6='', p7='', p8='', p9=''):
	var args = [p0, p1, p2, p3, p4, p5, p6, p7, p8, p9]
	var path = ""
	var index = -1
	for p in args:
		index += 1
		p = normalize(p)
		if p.empty():
			continue
		var sep = '/'
		if path.ends_with('/') or p.begins_with('/') or index <= 0:
			sep = ''
		path += str(sep, p)
	return path

# Check is the path is under target directory  
# This just simple check with file path strings so it won't check the file or 
#	directory in your file system
# - - - - - - - - - -  
# *Parameters*  
# * [path:String] The file path  
# * [dir:String] The parent directory path  
# - - - - - - - - - -  
# *Returns* bool  
# * Is the file with `path`	is under the directory ` dir`
static func path_under_dir(path, dir):
	var d = normalize(dir)
	if not d.ends_with('/'):
		d += '/'
	var p = normalize(path)
	return p.begins_with(d) and p != d

#  Get sub-path from the parent directory  
# - - - - - - - - - -  
# *Parameters*  
# * [path:String] The file path  
# * [dir:String] The parent directory path  
# - - - - - - - - - -  
# *Returns* String
# * The sub-path string
static func relative_to_parent_dir(path, dir):
	var p = path
	if path_under_dir(p, dir):
		p = normalize(p)
		var d = normalize(dir) + '/'
		p = p.substr(d.length(), p.length())
	return p

#  Normalize the file path this file replace all `\`  and `//` to `/ `  
# - - - - - - - - - -  
# *Parameters*  
# * [p_path:String] The file path to normalize to  
# - - - - - - - - - -  
# *Returns* String
# * The formated string
static func normalize(p_path):
	var replacement = {
		'\\': '/',
		'//': '/'
	}
	var path = p_path
	for key in replacement:
		path = path.replace(key, replacement[key])
	return path
