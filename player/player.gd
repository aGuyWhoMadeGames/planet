extends CharacterBody3D

var up = Vector3.UP

var hook_active = false
var hook_pos = Vector3()

@export var walk_speed = 3
@export var run_speed = 5
@export var friction = 0.85
@export var gravity = 2
@export var jump_power = 50

@onready var input := $input

# Workaround for velocity not being exposed in the editor.
@export var vel:Vector3:
	set(v):
		velocity = v
	get:
		return velocity

func _ready():
	tpllstr("83.34539020630596, -55.66442482887864")
	up = position.normalized()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	$Camera3D/RayCast3D.add_exception(self)
	
	if multiplayer.get_unique_id() == get_multiplayer_authority():
		$Camera3D.current = true
		$Camera3D/MeshInstance3D2.layers = 2
		$Camera3D/MeshInstance3D3.layers = 2
		GlobalData.observer = self
		GlobalData.player = self
		
		add_child(load("res://player/freecam.gd").new())

func _physics_process(delta):
	var frame:RefrenceFrame = get_tree().get_first_node_in_group("active_frame")
	if frame and not frame.first_frame and not is_on_floor():
		var pos:Vector3 = frame.global_location.basis * position
		var prev_pos:Vector3 = frame.global_location.basis.rotated(frame.axis_of_rotation, 2*PI*delta/frame.rotational_period) * (position - get_position_delta())
		
		var vel:Vector3 = pos.cross(frame.angular_velocity)
		var prev_vel:Vector3 = prev_pos.cross(frame.angular_velocity)
		
		var diff = vel - prev_vel
		
		velocity -= frame.global_location.basis.inverse() * diff
		
	
	velocity += $Camera3D.global_transform.basis * Vector3.BACK*10*input.click
	
	var movement2 = input.movement2
	var movement = Vector3(movement2.x,0,movement2.y)
	
	movement = transform.basis * movement
	movement = movement.rotated(up, $Camera3D.rotation.y)
	
	velocity += movement
	
	var f = Gravity.get_force(global_position)*delta
	velocity += f
	up = -f.normalized()
	
	if is_on_floor():
		velocity *= friction
		if input.jump:
			velocity += up * jump_power
	
	set_up_direction(up.normalized())
	
	move_and_slide()
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
	
	if Input.is_action_just_pressed("unstuck"):
		position = position.normalized() * ($"../../planet/planet".height+(1<<$"../../planet/planet".size-1))
		velocity = Vector3.ZERO
	
	
	if Input.is_action_just_pressed("left_click"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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
	position = position.normalized() * ($"../../planet/planet".height+(1<<$"../../planet/planet".size-1))
	transform = align_with_y(transform,up)
