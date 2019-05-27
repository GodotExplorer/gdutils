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
