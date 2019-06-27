# Simple tool to pack images into an atlas

tool
const json = preload("json.gd")

var	max_size = Vector2(2048, 2048)
var source_images = {}
var atlas_texture: Image = null
var frames = {}
var margin = Vector2(2, 2)

func clear():
	source_images = []

func add_image(id, image: Image):
	if image != null and image is Image:
		source_images[id] = image

func pack():
	self.frames = {}
	var temp_img = Image.new()
	temp_img.create(max_size.x, max_size.y, false, Image.FORMAT_RGBA8)
	var bottom = 0
	var right = 0
	var cur_frame_pos = Vector2()
	for id in source_images:
		var img = source_images[id]
		var image_size = img.get_size()
		if cur_frame_pos.y + image_size.y > max_size.y: break
		temp_img.blit_rect(img, Rect2(Vector2(), image_size), cur_frame_pos)
		self.frames[id] = Rect2(cur_frame_pos, image_size)
		bottom = max(cur_frame_pos.y + image_size.y + margin.y, bottom)
		right = max(right, cur_frame_pos.x + image_size.x)
		cur_frame_pos.x += image_size.x + margin.x
		if cur_frame_pos.x + image_size.x > max_size.x:
			cur_frame_pos.x = 0
			cur_frame_pos.y = bottom
	self.atlas_texture = Image.new()
	atlas_texture.create(right, bottom, false, Image.FORMAT_RGBA8)
	atlas_texture.blit_rect(temp_img, Rect2(Vector2(), Vector2(right, bottom)), Vector2())
	return OK

func export_atlas(path):
	var err = atlas_texture.save_png(path)
	if err == OK:
		var atlas = {
			"texture": path.get_file(),
			"frames": {},
			"width": atlas_texture.get_width(),
			"height": atlas_texture.get_height(),
		}
		for frame in frames:
			var rect: Rect2 = frames[frame]
			atlas.frames[frame] = {"x": rect.position.x, "y": rect.position.y, "w": rect.size.x, "h": rect.size.y}
		var atlas_config_file = path.replace(".png", ".json")
		err = json.save_json(atlas, atlas_config_file)
	return err
