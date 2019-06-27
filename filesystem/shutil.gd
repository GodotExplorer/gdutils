# The shutil module offers a number of high-level operations on files and collections of files.
# In particular, functions are provided which support file copying and removal.

tool

# Copy the file `src` to the file `dst`.  
# Permission bits are ignored. `src` and `dst` are path names given as strings.  
# - - -  
# **Parameters**  
# * src: String The source file to copy from  
# * dst: String The destination file to copy  
# * buff_size: int The buffer size allocated while coping files  
# - - -  
# **Return**  
# * Error the OK or error code  
static func copy(src, dst, buff_size=64*1024):
	var fsrc = File.new()
	var err = fsrc.open(src, File.READ)
	if OK == err:
		var dir = Directory.new()
		if not dir.dir_exists(dst.get_base_dir()):
			err = dir.make_dir_recursive(dst.get_base_dir())
		if OK == err:
			var fdst = File.new()
			err = fdst.open(dst, File.WRITE)
			if OK == err:
				var page = 0
				while fsrc.get_position() < fsrc.get_len():
					var sizeleft = fsrc.get_len() - fsrc.get_position()
					var lenght = buff_size if sizeleft > buff_size else sizeleft
					var buff = fsrc.get_buffer(lenght)
					fdst.store_buffer(buff)
					page += 1
				fdst.close()
				fsrc.close()
	return err
