
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
