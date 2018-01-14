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
extends ImageTexture

export var color1 = Color("#666666") setget _set_color1
export var color2 = Color("#999999") setget _set_color2

export(int) var cell_size = 10 setget _set_cell_size

func _init():
    _update_image()

func _set_cell_size(p_size):
	cell_size = p_size
	_update_image()

func _set_color1(p_color):
	color1 = p_color
	_update_image()

func _set_color2(p_color):
	color2 = p_color
	_update_image()

func _update_image():
    var image = Image.new()
    image.create(cell_size * 2, cell_size * 2, false, Image.FORMAT_RGBA8)
    image.fill(color2)
    image.lock()
    for x in range(cell_size):
        for y in range(cell_size):
            image.set_pixel(x, y, color1)
    for x in range(cell_size, cell_size * 2):
        for y in range(cell_size, cell_size * 2):
            image.set_pixel(x, y, color1)
    image.unlock()
    create_from_image(image)
