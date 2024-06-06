extends ColorRect


var player = Node3D.new()

func _process(_delta):
	var v = player.position
	v = v.normalized()
	var lat = acos(v.y)/PI
	var long = acos(v.x/max(Vector2(v.x,v.z).length(),0.01))/(PI*2)
	long *= -sign(v.z)
	long += 0.5
	
	anchor_left = long
	anchor_right = long
	anchor_top = lat
	anchor_bottom = lat
