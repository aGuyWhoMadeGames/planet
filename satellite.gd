@tool
extends RefrenceFrame

@export_node_path("Planet") var planet_path :
	set(path):
		planet_path = path
		planet = get_node_or_null(path)
		
		if planet:
			semi_major_axis = altitude + 1<<(planet.size-1)

@export var altitude = 100.0 :
	set(x):
		altitude = x
		if planet:
			semi_major_axis = altitude + (1<<(planet.size-1))

@export var semi_major_axis = 1124.0 :
	set(x):
		semi_major_axis = x
		if planet:
			var new_altitude = semi_major_axis - (1<<(planet.size-1))
			if altitude != new_altitude:
				altitude = new_altitude

@onready var planet:Planet = get_node(planet_path)

var time = 0

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	time += delta
	
	var a = semi_major_axis
	var GM = planet.mass*Gravity.G
	
	var T = 2*PI*sqrt(a*a*a/GM)
	var M = 2*PI*fmod(time,T)/T
	
	var up = Vector3.FORWARD.rotated(Vector3.UP,M+PI)
	
	global_location.basis = Basis(Vector3.UP,M)
	global_location.origin = up*semi_major_axis
	
	linear_acceleration = -up*GM/(a*a)
	linear_velocity = up.rotated(Vector3.UP,PI/2)*sqrt(GM/a)
	
	rotating = true
	rotational_period = T
	
	super._physics_process(delta)
