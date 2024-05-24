extends Node


var queue := []

var exit_mutex := Mutex.new()
var queue_mutex := Mutex.new()
var threads := []
var exit_thread = false

func _ready():
	for i in OS.get_processor_count()>>1:
		var thread = Thread.new()
		threads.append(thread)
		thread.start(Callable(self, "_thread_function"))


func add(node:Node):
	queue_mutex.lock()
	queue.append(node)
	queue_mutex.unlock()

func _process(_delta):
	pass

func _thread_function():
	while true:
		#semaphore.wait()
		OS.delay_msec(50)
		
		exit_mutex.lock()
		var should_exit = exit_thread
		exit_mutex.unlock()
		
		if should_exit:
			break
		
		var node
		queue_mutex.lock()
		if not queue.is_empty():
			
			print(len(queue))
			queue.sort_custom(Callable(self, "sort"))
			node = queue.pop_back()
		queue_mutex.unlock()
		
		if node:
			if not node.split():
				queue_mutex.lock()
				queue.append(node)
				queue_mutex.unlock()
		

static func sort(a,b):
	return a.d>b.d

func _exit_tree():
	# Set exit condition to true.
	exit_mutex.lock()
	exit_thread = true # Protect with Mutex.
	exit_mutex.unlock()

	for i in threads:
		i.wait_to_finish()
