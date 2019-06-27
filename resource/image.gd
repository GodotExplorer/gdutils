# some useful functions for image files

tool

# Load image texture from external path  
# - - -  
# **Parameters**  
# * [path: String] The absolute image path  
# - - -  
# **Returns**  
# * ImageTexture | null
static func load_image_texture(path):
	var img = Image.new()
	if OK == img.load(path):
		var tex = ImageTexture.new()
		tex.create_from_image(img)
		return tex
	return null

# Save image into png file  
# - - -  
# **Parameters**  
# * [texture: Image|ImageTexture] The image or texture to save  
# * [path: String] The file path to save with  
# - - -  
# **Returns**  
# *  [int] OK | error code
static func save_image_texture(texture, path):
	if texture == null or typeof(texture) != TYPE_OBJECT or typeof(path) != TYPE_STRING:
		return ERR_INVALID_PARAMETER
	var img = null
	if texture is Image:
		img = texture
	elif texture is ImageTexture:
		img = texture.get_data()
	if img != null:
		return img.save_png(path)
	return ERR_INVALID_DATA
