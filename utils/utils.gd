
# Check does an object has all of script methods of target class  
# - - - - - - - - - -  
# *Parameters*  
# * [obj:Object] The object to check  
# * [interface:GDScript] The interface to check with 
# - - - - - - - - - -  
# *Returns* bool  
static func implements(obj: Object, interface:GDScript) -> bool:
	if obj == null or interface == null:
		return false
	if typeof(obj) != TYPE_OBJECT:
		return false
	if obj is interface:
		return true
	var interface_obj = interface.new()
	var required_methods = []
	for m in interface_obj.get_method_list():
		if m.flags & METHOD_FLAG_FROM_SCRIPT:
			required_methods.append(m.name)
	if not interface_obj is Reference:
		interface_obj.free()
	for mid in required_methods:
		if not obj.has_method(mid):
			return false
	return true

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
