# The task queue to run tasks in a seperated thread

tool
var running = false
var frame_interval = 1
var thread = Thread.new()
var task_queue = []

func post(object, method, params = [], callback_caller = null, callback = ''):
	var mutex = Mutex.new()
	mutex.lock()
	task_queue.push_back([object.get_instance_id(), method, params,  callback_caller.get_instance_id() if callback_caller != null else 0, callback])
	mutex.unlock()

func cancel(object, method, callback_caller = null, callback = ''):
	var mutex = Mutex.new()
	mutex.lock()
	var instance_id = object.get_instance_id()
	var cancel_tasks = []
	for task in task_queue:
		if task != null:
			if task[0] == instance_id and task[1] == method and callback_caller.get_instance_id() == task[3] and callback == task[4]:
				cancel_tasks.append(task)
	for t in cancel_tasks:
		task_queue.erase(t)
	mutex.unlock()

func start():
	running = true
	thread.start(self, "thread_main", get_instance_id())

func stop():
	running = false
	thread.wait_to_finish()

func thread_main(instance_id):
	var this = instance_from_id(instance_id)
	while this.running:
		if this.task_queue.size() > 0:
			var mutex = Mutex.new()
			mutex.lock()
			var task = this.task_queue[0]
			if task != null:
				this.task_queue.pop_front()
				mutex.unlock()
				mutex = null
				var instance = instance_from_id(task[0])
				if instance != null:
					var ret = instance.callv(task[1], task[2])
					var callback_caller = instance_from_id(task[3])
					if callback_caller:
						callback_caller.call_deferred(task[4], ret)
			if mutex != null:
				mutex.unlock()
			OS.delay_usec(this.frame_interval)
