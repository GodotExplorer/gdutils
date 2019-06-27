# The node to make http requests

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
    # rq.name = url.replace("/", '\\')
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
    if typeof(body) == TYPE_RAW_ARRAY:
        var type = get_content_type(headers)
        match type:
            'image/jpeg', 'application/x-jpg':
                var img = Image.new()
                img.load_jpg_from_buffer(body)
                return img
            'image/png', 'application/x-png':
                var img = Image.new()
                img.load_png_from_buffer(body)
                return img
            'image/webp':
                var img = Image.new()
                img.load_webp_from_buffer(body)
                return img
            'application/json':
                return parse_json(body.get_string_from_utf8())
        if type.begins_with("text/"):
            return body.get_string_from_utf8()
    return body

# Get content type from the response headers  
# - - - - - - - - - -  
# *Parameters*  
# * [headers: PoolStringArray] headers  
# - - - - - - - - - -  
# *Returns* String  
# * The content type with lower case or an empty string if parse faild
static func get_content_type(headers):
    var type = ''
    if typeof(headers) in [TYPE_STRING_ARRAY, TYPE_ARRAY]:
        for item in headers:
            item = item.to_lower()
            if item.begins_with('content-type:'):
                type = item.substr(len('content-type:'), len(item)).strip_edges()
                break
    return type


func _process(delta):
    for url in request_nodes:
        var rq = request_nodes[url]
        if rq.get_http_client_status() == HTTPClient.STATUS_BODY:
            emit_signal('request_progress', url, rq.get_downloaded_bytes(), rq.get_body_size())
    for node in get_children():
        if not node in request_nodes.values():
            node.queue_free()

func _on_request_completed(result, response_code, headers, body, url):
    if not url in request_nodes: return
    var rq = request_nodes[url]
    if result == HTTPRequest.RESULT_SUCCESS and response_code == HTTPClient.RESPONSE_OK:
        emit_signal('request_progress', url, rq.get_downloaded_bytes(), rq.get_body_size())
        emit_signal('request_completed', url, headers, body)
    else:
        emit_signal('request_failed', url, result, response_code)
    # remove the request node
    request_nodes[url].queue_free()
    request_nodes.erase(url)
