@tool
class_name RefrenceFrame
extends Node3D

@export var active = false :
	set(x):
		if x and is_inside_tree():
			get_tree().call_group("refrence_frames","deactivate")
			if get_tree().get_first_node_in_group("active_frame"):
				get_tree().get_first_node_in_group("active_frame").remove_from_group("active_frame")
			add_to_group("active_frame")
		active = x

@export var radius = 200.0

@export var use_physics_space = false

@export var global_location:Transform3D :
	set(x):
		global_location = x
		if Engine.is_editor_hint():
			transform = x

@export_group("Linear Motion")
@export var linear_velocity:Vector3 = Vector3.ZERO
@export var linear_acceleration:Vector3 = Vector3.ZERO

@export_group("Rotation")
@export var rotating = false :
	set(x):
		rotating = x
		update_angular_velocity()

@export var axis_of_rotation = Vector3.UP :
	set(x):
		axis_of_rotation = x
		update_angular_velocity()

@export var rotational_period = 60.0 :
	set(x):
		rotational_period = x
		update_angular_velocity()

var angular_velocity:Vector3 = Vector3.ZERO

var space:RID = PhysicsServer3D.space_create()

var first_frame:bool = false

func _ready() -> void:
	add_to_group("refrence_frames")

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if active:
		transform = Transform3D()
	else:
		if get_tree().get_first_node_in_group("active_frame"):
			transform = get_tree().get_first_node_in_group("active_frame").global_location.inverse() * global_location
		else:
			transform = global_location

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	first_frame = false
	
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	if active or not get_tree().get_first_node_in_group("active_frame"):
		var d = (player.position - position).length_squared()
		if active:
			if d > radius * radius + 10000:
				active = false
				remove_from_group("active_frame")
				player.velocity = global_location.basis * player.velocity
				player.velocity -= player.global_position.cross(angular_velocity)
				player.velocity += linear_velocity
				player.global_transform = global_location * player.global_transform
				if use_physics_space:
					for p in get_tree().get_nodes_in_group("players"):
						PhysicsServer3D.body_set_space(p.get_rid(),get_world_3d().space)
		else:
			if d < radius * radius:
				active = true
				first_frame = true
				player.global_transform = global_location.inverse() * player.global_transform
				player.velocity -= linear_velocity
				player.velocity = global_location.basis.inverse() * player.velocity
				player.velocity += player.global_position.cross(angular_velocity)
				if use_physics_space:
					for p in get_tree().get_nodes_in_group("players"):
						PhysicsServer3D.body_set_space(p.get_rid(),space)

func deactivate():
	active = false

func update_angular_velocity():
	if rotating:
		angular_velocity = axis_of_rotation * 2 * PI / rotational_period
	else:
		angular_velocity = Vector3.ZERO
