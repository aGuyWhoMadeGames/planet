@tool
class_name PlanetGeneratorImage
extends PlanetGenerator

@export var heightmap:Image
@export var filter = false

func _get_height(v:Vector3) -> float:
	var lat = acos(v.y)
	var long = acos(v.x/max(Vector2(v.x,v.z).length(),0.01))
	long *= -sign(v.z)
	var x = (long/(PI)+1)*heightmap.get_height()
	var y = (lat/(PI*2))*heightmap.get_width()
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
	return h
