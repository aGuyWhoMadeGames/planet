extends Camera3D

func _init():
	far = 524288
	fov = 90

func _physics_process(delta):
	var movement = Vector3.ZERO
	if Input.is_action_pressed("ui_up"):
		movement.z -= 1
	if Input.is_action_pressed("ui_down"):
		movement.z += 1
	if Input.is_action_pressed("ui_left"):
		movement.x -= 1
	if Input.is_action_pressed("ui_right"):
		movement.x += 1
	
	if Input.is_action_pressed("crouch"):
		movement *= 10000
	elif Input.is_action_pressed("sprint"):
		movement *= 100
	else:
		movement *= 10
	
	position += transform.basis * (movement*delta)
#	translation += movement

func _input(event):
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x/300
		rotation.x -= event.relative.y/300
		if rotation_degrees.x > 90:
			rotation_degrees.x = 90
		if rotation_degrees.x < -90:
			rotation_degrees.x = -90
	
	if Input.is_action_just_pressed("freecam"):
		if current:
			$"../Camera3D".current = true
		else:
			current = true
			position = Vector3(0,1.65,0)
