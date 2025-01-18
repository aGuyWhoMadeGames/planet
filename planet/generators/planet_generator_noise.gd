@tool
class_name PlanetGeneratorNoise
extends PlanetGenerator

@export var height = 50.0
@export var scale = 1000.0

@export var noise:Noise

func _get_height(v:Vector3) -> float:
	var h = noise.get_noise_3dv(v*scale)
	return remap(h,-1,1,0,1)*height
