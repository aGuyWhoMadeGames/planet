@tool
class_name PlanetGeneratorCurve
extends PlanetGenerator

@export var height = 50.0
@export var curve:Curve
@export var generator:PlanetGenerator

func _get_height(v:Vector3) -> float:
	return curve.sample_baked(generator._get_height(v))*height
