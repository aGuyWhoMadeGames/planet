@tool
class_name PlanetGeneratorAdd
extends PlanetGenerator

@export var generator_a:PlanetGenerator
@export var generator_b:PlanetGenerator

func _get_height(v:Vector3) -> float:
	return generator_a._get_height(v)+generator_b._get_height(v)
