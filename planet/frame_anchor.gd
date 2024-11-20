@tool
class_name FrameAnchor
extends Node3D

@export var global_location:Vector3 :
	set(x):
		global_location = x
		if Engine.is_editor_hint():
			position = x

@export var global_orientation:Basis :
	set(x):
		global_orientation = x
		if Engine.is_editor_hint():
			basis = x

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if get_tree().get_first_node_in_group("active_frame"):
		transform = get_tree().get_first_node_in_group("active_frame").global_location.inverse() * Transform3D(global_orientation,global_location)
	else:
		transform = Transform3D(global_orientation,global_location)
