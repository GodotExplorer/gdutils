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

const AsyncTaskQueue = preload("AsyncTaskQueue.gd")
const InstanceManager = preload("InstanceManager.gd")
const csv = preload("csv.gd")
const http = preload("http.gd")
const json = preload("json.gd")
const uuid = preload("uuid.gd")

static func implements(obj, interface= {}):
	if obj == null or interface == null:
		return false
	if not (typeof(obj) == TYPE_OBJECT):
		return false
	if typeof(interface) == TYPE_OBJECT and obj is interface:
		return true
	return false

# Format the time duration to a text to display  
# - - - - - - - - - -  
# *Parameters*  
# * [seconds: float] The time duration in seconds  
# * [always_show_hours: bool = `false`] Show hours even if the time is less than one hour
# - - - - - - - - - -  
# *Returns* String  
# * The time duration as `hh:mm:ss`
static func format_time_duration(second: float, always_show_hours = false) -> String:
	var h = floor(second / (60.0 * 60.0))
	var m = floor((second - h * 60.0 * 60.0) / 60.0)
	var s = int(second) % 60
	var ret = ""
	if h > 0 or always_show_hours:
		if h < 10: ret += "0"
		ret += str(h, ":")
	if m < 10: ret += "0"
	ret += str(m, ":")
	if s < 10: ret += "0"
	ret += str(s)
	return ret

