@tool
class_name PlanetGeneratorMix
extends PlanetGenerator

@export_range(0.0,1.0) var factor = 0.5
@export var generator_a:PlanetGenerator
@export var generator_b:PlanetGenerator

func _get_height(v:Vector3) -> float:
	return lerp(generator_a._get_height(v),generator_b._get_height(v),factor)
