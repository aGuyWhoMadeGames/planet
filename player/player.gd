extends CharacterBody3D

var up = Vector3.UP

var hook_active = false
var hook_pos = Vector3()

@export var walk_speed = 3
@export var run_speed = 5
@export var friction = 0.85
@export var gravity = 2
@export var jump_power = 50

func _physics_process(delta):
	
	#up = position.normalized()
	
#	if hook_active:
#		velocity += (hook_pos - translation).normalized() * 5
	
	if Input.is_action_pressed("right_click"):
		velocity -= $Camera3D.global_transform.basis * (Vector3.FORWARD)*10
	if Input.is_action_pressed("left_click"):
		velocity -= $Camera3D.global_transform.basis * (Vector3.BACK)*10
	
	var movement = Vector3()
	if Input.is_action_pressed("ui_up"):
		movement.z -= 1
	if Input.is_action_pressed("ui_down"):
		movement.z += 1
	if Input.is_action_pressed("ui_left"):
		movement.x -= 1
	if Input.is_action_pressed("ui_right"):
		movement.x += 1
	
	if Input.is_action_pressed("sprint"):
		movement *= run_speed
	else:
		movement *= walk_speed
	
	movement *=  int($Camera3D.current)
	
	movement = transform.basis * (movement)
	movement = movement.rotated(up, $Camera3D.rotation.y)
	velocity += movement
	var rotated_vel = transform.basis.inverse() * (velocity)
#	rotated_vel *= Vector3(friction, 1, friction)
	velocity = transform.basis * (rotated_vel)
	#velocity *= friction
	#velocity *= Vector3(friction, 1, friction)
	#velocity -= up * gravity
	
	var f = Gravity.get_force(global_position)*delta
	velocity += f
	up = -f.normalized()
	
	if is_on_floor():
		velocity *= friction
		if Input.is_action_pressed("jump"):
			velocity += up * jump_power
	
	set_velocity(velocity)
	set_up_direction(up.normalized())
	move_and_slide()
	velocity = velocity
	
	#view_up = view_up.move_toward(up, 0.03).normalized()
	#transform = transform.interpolate_with(align_with_y(transform, up), 0.2)
	transform = align_with_y(transform, up)

func _input(event):
	
	if event is InputEventMouseMotion:
		if $Camera3D.current:
			$Camera3D.rotation.y -= event.relative.x/300
			$Camera3D.rotation.x -= event.relative.y/300
			if $Camera3D.rotation_degrees.x > 90:
				$Camera3D.rotation_degrees.x = 90
			if $Camera3D.rotation_degrees.x < -90:
				$Camera3D.rotation_degrees.x = -90
			
			#$"../Multiplayer".rpc("update_view", $Camera3D.rotation)
		
	
	if Input.is_action_just_pressed("unstuck"):
		position = position.normalized() * ($"../planet".height+(1<<$"../planet".size-1))
	
	
	if Input.is_action_just_pressed("left_click"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#		if $Camera/RayCast.is_colliding():
#			hook_active = true
#			hook_pos = $Camera/RayCast.get_collision_point()
#
#	if Input.is_action_just_released("left_click"):
#		hook_active = false

func _ready():
	tpllstr("83.34539020630596, -55.66442482887864");
	up = position.normalized()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	$Camera3D/RayCast3D.add_exception(self)

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform

func tpllstr(s:String):
	var a = s.split_floats(",")
	tpll(a[0],a[1])

func tpll(lat,lon):
	lat = deg_to_rad(lat)
	lon = deg_to_rad(-lon)
	
	var v = Vector3()
	v.y = sin(lat)
	var z = cos(lat)
	v.x = cos(lon)*z
	v.z = sin(lon)*z
	position = v
	position = position.normalized() * ($"../planet".height+(1<<$"../planet".size-1))
	transform = align_with_y(transform,up)
