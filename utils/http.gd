##################################################################################
#    http.gd                                                                     #
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
extends Node

signal request_completed(url, headers, body)
signal request_failed(url, result, response_code)
signal request_progress(url, value, max_size)

# url : HTTPRequest
var request_nodes = {}

# Start a http requestion  
# - - - - - - - - - -  
# *Parameters*  
# * [url: String] The url of the requestion  
# * [method: HTTPClient.Method ] The method of the requestion  
# * [headers: PoolStringArray ] Headers send to url for this request  
# * [body: String ] Datas of the request
# - - - - - - - - - -  
# *Returns* Error  
# * Return OK or other error code
func request(url, method = HTTPClient.METHOD_GET, headers=[], body = ""):
    var rq = HTTPRequest.new()
    rq.use_threads = true
    rq.connect("request_completed", self, "_on_request_completed", [url])
    add_child(rq)
    var ret = rq.request(url, headers, false, method, body)
    if OK == ret:
        request_nodes[url] = rq
    else:
        rq.queue_free()
    return ret

# Cancel request for target url request  
# - - - - - - - - - -  
# *Parameters*  
# * [url: String] the url of the request
func cancel_request(url):
    if url in request_nodes:
        var rq = request_nodes[url]
        rq.cancel_request()
        rq.queue_free()
        request_nodes.erase(url)

# Resolve respose data  
# - - - - - - - - - -  
# *Parameters*  
# * [headers: PoolStringArray] response headers  
# * [body: PoolByteArray] raw response data  
# - - - - - - - - - -  
# *Returns* Variant  
# * Return the resolved result or the body if not resolved
static func resolve_respose_body(headers, body):
    if typeof(body) == TYPE_RAW_ARRAY and typeof(headers) == TYPE_STRING_ARRAY:
        for item in headers:
            item = item.to_lower()
            if item.begins_with('content-type:'):
                var type = item.substr(len('content-type:'), len(item)).strip_edges()
                match type:
                    'image/jpeg', 'application/x-jpg':
                        var img = Image.new()
                        img.load_jpg_from_buffer(body)
                        return img
                    'image/png', 'application/x-png':
                        var img = Image.new()
                        img.load_png_from_buffer(body)
                        return img
                    'application/json':
                        return parse_json(body.get_string_from_utf8())
                if type.begins_with("text/"):
                    return body.get_string_from_utf8()
    return body


func _process(delta):
    for url in request_nodes:
        var rq = request_nodes[url]
        if rq.get_http_client_status() == HTTPClient.STATUS_BODY:
            emit_signal('request_progress', url, rq.get_downloaded_bytes(), rq.get_body_size())

func _on_request_completed(result, response_code, headers, body, url):
    if not url in request_nodes: return
    var rq = request_nodes[url]
    if result == HTTPRequest.RESULT_SUCCESS and response_code == HTTPClient.RESPONSE_OK:
        emit_signal('request_progress', url, rq.get_downloaded_bytes(), rq.get_body_size())
        emit_signal('request_completed', url, headers, body)
    else:
        emit_signal('request_failed', url, result, response_code)
    if url in request_nodes:
        request_nodes[url].queue_free()
        request_nodes.erase(url)