# Load text file content as string  
# - - -  
# **parameter**  
# * [path: String] file path to load  
# - - -  
# **Return**  
# * String file content
static func load_text_content(path):
	var file = File.new()
	if OK == file.open(path, File.READ):
		return file.get_as_text()
	return ""

# Save text into file  
# - - -  
# **parameter**  
# * [text: String] The text content to save  
# * [path: String] The file path to save with  
# - - -  
# **Return**  
# * in : OK | error code  
static func save_text_content(text, path):
	var file = File.new()
	var err = file.open(path, File.WRITE)
	if OK == err:
		file.store_string(text)
	return err
