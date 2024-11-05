extends Node

const G = 7000000

func get_force(p:Vector3)->Vector3:
	var f := Vector3.ZERO
	for b in get_tree().get_nodes_in_group("gravity_wells"):
		var v:Vector3 = b.global_transform.origin - p
		var d:float = v.length_squared()
		f += (v.normalized()*b.mass*G)/d
	return f
