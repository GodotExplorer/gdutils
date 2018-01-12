##################################################################################
#                        Tool generated DO NOT modify                            #
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

# Load image texture from external path  
# - - -  
# **Parameters**  
# * [path: String] The absolute image path  
# - - -  
# **Returns**  
# * ImageTexture | null
static func load_external_image_texture(path):
	var tryTex = load(path)
	if typeof(tryTex) == TYPE_OBJECT and tryTex != null and tryTex is Texture:
		return tryTex
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
