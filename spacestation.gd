extends StaticBody3D

@onready var prev = global_position

func _physics_process(delta):
	constant_linear_velocity = (global_position-prev)/delta
	prev = global_position
