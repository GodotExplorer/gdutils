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
extends TextureRect
export var color1 = Color("#666666") setget _set_color1
export var color2 = Color("#999999") setget _set_color2
export(int) var cell_size = 10 setget _set_cell_size

var grid_texture = preload("../../resource/GridBackgroundTexture.gd").new()

func _init():
    self.texture = grid_texture
    self.expand = true
    self.stretch_mode = TextureRect.STRETCH_TILE

func _set_color1(p_color):
	color1 = p_color
	grid_texture.color1 = p_color

func _set_color2(p_color):
	color2 = p_color
	grid_texture.color2 = p_color

func _set_cell_size(p_size):
    cell_size = p_size
    var cell_size_dpi_related = int(p_size * OS.get_screen_dpi() / 72.0)
    grid_texture.cell_size = cell_size_dpi_related


