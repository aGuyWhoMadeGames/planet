@tool
extends Node3D
class_name Terrain

@export var reload = false: set = refresh
var size
var lod
var material:Material
var height = 10.0
var generator:PlanetGenerator


func _ready():
	refresh()

func get_params():
	size = get_parent().size
	lod = get_parent().lod
	material = get_parent().material
	height = get_parent().height
	generator = get_parent().generator

func refresh(_a=null):
	get_params()
	for i in get_children():
		i.queue_free()
	var task = start.bind([Vector2.ZERO,size-6,self,
	transform,get_world_3d().scenario,get_world_3d().space])
	
	task.call()
	#if get_parent().priority:
		#task.call()
	#else:
		#WorkerThreadPool.add_task(task)

func start(args):
	#if not get_parent().priority:
		#OS.delay_msec(randi()%1000)
	call_thread_safe("add_child",QuadNode.new.callv(args))

