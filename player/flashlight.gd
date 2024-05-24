extends SpotLight3D


func _process(_delta):
	global_basis = $"../Camera3D".global_basis
	position = Vector3(0,1,0)

func _input(_event):
	if Input.is_action_just_pressed("flashlight"):
		visible = !visible
