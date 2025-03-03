@tool
class_name Planet
extends Node3D

@export var refresh = false: set = refresh_setget
@export var priority = false
@export var size = 10
@export var mass = 1000.0
@export var lod = 0
@export var material:Material
@export var generator:PlanetGenerator


func _init():
	for i in [
		Vector3(0,0,0),
		Vector3(90,0,0),
		Vector3(90,90,0),
		Vector3(90,180,0),
		Vector3(90,-90,0),
		Vector3(180,0,0),
	]:
		var face = Terrain.new()
		face.rotation_degrees = i
		add_child(face)

func refresh_setget(_a=null):
	for i in get_children():
		if "reload" in i:
			i.reload = true

func _ready():
	add_to_group("gravity_wells")
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	refresh = true
