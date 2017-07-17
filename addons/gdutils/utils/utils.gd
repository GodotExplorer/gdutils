static func implements(obj, interface= {}):
	if obj == null or interface == null:
		return false
	if not (typeof(obj) == TYPE_OBJECT):
		return false
	if typeof(interface) == TYPE_OBJECT and obj is interface:
		return true
	return false