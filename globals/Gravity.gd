extends Node

var bodies:Array = []

const G = 7000000

func get_force(p:Vector3)->Vector3:
	var f := Vector3.ZERO
	for b in bodies:
		var v:Vector3 = b.global_transform.origin - p
		var d:float = v.length_squared()
		f += (v.normalized()*b.mass*G)/d
	return f

func add_body(b)->void:
	bodies.append(b)
