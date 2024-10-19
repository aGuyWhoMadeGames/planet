@tool
class_name PlanetGeneratorNoise
extends PlanetGenerator

@export var scale = 1000.0
@export_range(-1.0,1.0) var ocean_value = -1.0
@export var noise:Noise

func _get_height(v:Vector3) -> float:
	var h = noise.get_noise_3dv(v*scale)
	return max(0.0, remap(h,ocean_value,1.0,0.0,1.0))
