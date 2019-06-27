# The control to load texture in background

tool
extends TextureRect

enum State {
	IDLE,
	LOADING,
	FAILED,
	SUCCESS
}


var container = CenterContainer.new()
var state = State.IDLE	setget _set_state
export var url = "" setget _set_url
export(PackedScene) var progress_template = null
var progress_node = null
export(PackedScene) var failed_template = null
var failed_node = null
var _pending_load = false

func _init():
	container.name = "PresetControls"
	container.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(container)

func _set_url(value):
	if url == value and (state in [State.LOADING, State.SUCCESS]):
		return
	url = value
	self.texture = null
	if not value.empty():
		_pending_load = true
		set_process(true)

# *virtual* Do async load action here don't forget change state
func _async_load_url():
	pass

func _set_state(p_state):
	state = p_state
	if progress_node: progress_node.hide()
	if failed_node: failed_node.hide()
	match state:
		State.LOADING:
			if progress_node: progress_node.show()
		State.FAILED:
			if failed_node: failed_node.show()

func _ready():
	if progress_template != null:
		var node = progress_template.instance()
		if node != null:
			progress_node = node
			progress_node.name = "progress"
			container.add_child(progress_node)
			if progress_node.has_method('set_min'):
				progress_node.set_min(0)
	if failed_template != null:
		var node = failed_template.instance()
		if node != null:
			failed_node = node
			failed_node.name = "failed"
			container.add_child(failed_node)
	# initialize properties
	self.state = State.IDLE
	self.url = url

func _process(delta):
	if _pending_load:
		_pending_load = false
		set_process(false)
		# Don't load the image in the editor as it will save the data to the scene
		if Engine.editor_hint:
			printt("AsyncTextureRect: ignored loading url ", url)
			return
		# run async load action
		_async_load_url()
