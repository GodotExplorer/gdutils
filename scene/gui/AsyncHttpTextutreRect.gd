##################################################################################
#    AsyncHttpTextutreRect.gd                                                    #
##################################################################################
#                            This file is part of                                #
#                                GodotExplorer                                   #
#                       https://github.com/GodotExplorer                         #
##################################################################################
# Copyright (c) 2017-2018 Godot Explorer                                         #
#                                                                                #
# Permission is hereby granted, free of charge, to any person obtaining a copy   #
# of this software and associated documentation files (the "Software"), to deal#
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
	