# A random pool to select random items in the pool with weight support

tool
class RandomItem:
	var weight: float = 1
	var start: float = 0
	var data = null

var _items = []
var _next_item_weight_start: float = 0

# Add item with weight to the random pool
# - - - - - - - - - -  
# *Parameters*  
# * [data:Variant] The item data of the random item 
# * [weight:float] The weight of this item in the random pool 
func add_item(data, weight: float = 1):
	var w = abs(weight)
	var item = RandomItem.new()
	item.data = data
	item.weight = w
	item.start = self._next_item_weight_start
	self._next_item_weight_start += w
	_items.append(item)

# Update the weight chain of the pool  
# - - - - - - - - - -  
# *Returns* float  
# * Return the sum of weights
func update():
	self._next_item_weight_start = 0
	for item in _items:
		item.start = self._next_item_weight_start
		self._next_item_weight_start += item.weight
	return self._next_item_weight_start


# Random select item from the pool according to thier weight 
# - - - - - - - - - -  
# *Parameters*  
# * [count:int] number of items to get from the pool
# * [norepeat:false] Allow repeat items in the returned items
# - - - - - - - - - -  
# *Returns* Array  
# * Return the selected selected items
func random(count: int = 1, norepeat = false) -> Array:
	var ret = []
	if norepeat and count >= self._items.size():
		for item in self._items:
			ret.append(item.data)
		ret.shuffle()
		return ret
	var selected_item: RandomItem = null
	var rand_num = rand_range(0, self._next_item_weight_start)
	for item in self._items:
		if rand_num >= item.start and rand_num < item.start + item.weight:
			selected_item = item
			break
	if count > 1:
		var pool = get_script().new()
		if norepeat:
			pool._items = self._items.duplicate()
			if selected_item:
				pool._items.erase(selected_item)
		else:
			pool._items = self._items
		pool.update()
		ret = pool.random(count - 1, norepeat)
	if selected_item:
		ret.append(selected_item.data)
	return ret
