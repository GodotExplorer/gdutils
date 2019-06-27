# The control to display remote picture via http request

extends "AsyncTextureRect.gd"
var http = preload("../../utils/http.gd").new()

func _init().():
	http.name = "http"
	http.connect("request_completed", self, '_on_http_request_done')
	http.connect("request_failed", self, '_on_http_request_failed')
	http.connect("request_progress", self, '_on_http_request_progress')
	add_child(http)

func _async_load_url():
	if OK == http.request(url):
		self.state = State.LOADING
	else:
		self.state = State.FAILED

func _on_http_request_done(p_url, headers, body):
	if p_url == self.url:
		var img = http.resolve_respose_body(headers, body)
		if typeof(img) == TYPE_OBJECT and img is Image:
			var tex = ImageTexture.new()
			tex.create_from_image(img)
			self.texture = tex
			self.state = State.SUCCESS
		else:
			self.state = State.FAILED

func _on_http_request_failed(p_url, result, response_code):
	if url == p_url:
		self.state = State.FAILED

func _on_http_request_progress(p_url, value, max_size):
	if p_url == self.url and progress_node != null:
		if progress_node.has_method('set_max'):
			progress_node.set_max(max_size)
		if progress_node.has_method('set_value'):
			progress_node.set_value(value)
	