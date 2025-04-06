@tool
class_name PlanetGeneratorImage
extends PlanetGenerator

@export var min_height = 0.0
@export var max_height = 50.0
@export var heightmap:Image
@export var filter = false

func _get_height(v:Vector3) -> float:
	var long = -atan2(v.z,v.x)
	var lat = -atan2(v.y,Vector2(v.x,v.z).length())
	var x = (long/PI+1)*(heightmap.get_height()-1)
	var y = (lat/PI*0.5+0.25)*(heightmap.get_width()-1)
	var h:float
	if filter:
		h = heightmap.get_pixel(int(x)%heightmap.get_width(),int(y)%heightmap.get_height()).r
		var hx = heightmap.get_pixel(int(x+1)%heightmap.get_width(),int(y)%heightmap.get_height()).r
		var hy = heightmap.get_pixel(int(x)%heightmap.get_width(),int(y+1)%heightmap.get_height()).r
		var hxy = heightmap.get_pixel(int(x+1)%heightmap.get_width(),int(y+1)%heightmap.get_height()).r
		var h0 = lerp(h,hx,fmod(x,1))
		var h1 = lerp(hy,hxy,fmod(x,1))
		h = lerp(h0,h1,fmod(y,1))
	else:
		h = heightmap.get_pixel(int(x)%heightmap.get_width(),int(y)%heightmap.get_height()).r
	return remap(h,0,1,min_height,max_height)
