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
extends EditorPlugin
const gdutils = preload("__init__.gd")
var tools = preload("editor/tools.gd").new()

func _enter_tree():
	add_custom_type("AsyncHttpTextureRect", "TextureRect", gdutils.scene.gui.AsyncHttpTextutreRect, null)
	add_custom_type("ItemListEnhanced", "ItemList", gdutils.scene.gui.ItemListEnhanced, null)
	add_custom_type("InfinityList", "ScrollContainer", gdutils.scene.gui.InfinityList, null)
	add_custom_type("GridBackground", "TextureRect", gdutils.scene.gui.GridBackground, null)

func _ready():
	tools.initialize(self)

func _exit_tree():
	remove_custom_type("AsyncHttpTextureRect")
	remove_custom_type("AutoLayoutControl")
	remove_custom_type("ItemListEnhanced")
	remove_custom_type("InfinityList")
	remove_custom_type("GridBackground")
