@tool
class_name PlanetGeneratorCurve
extends PlanetGenerator

@export var curve:Curve
@export var generator:PlanetGenerator

func _get_height(v:Vector3) -> float:
	return curve.sample_baked(generator._get_height(v))
