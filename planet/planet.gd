@tool
extends Node3D

@export var refresh = false: set = refresh_setget
@export var priority = false
@export var size = 10
@export var mass = 1000.0
@export var lod = 0
@export var material:Material
#export var tree:PackedScene
#export var far_tree:Mesh
@export var height = 10.0
@export var heightmap:Image 
@export var noise:FastNoiseLite 

func refresh_setget(_a):
	for i in get_children():
		if "reload" in i:
			i.reload = true

func _ready():
	Gravity.add_body(self)
	refresh = true
	process_mode = Node.PROCESS_MODE_ALWAYS
