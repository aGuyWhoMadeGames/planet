extends MeshInstance3D


@export var player_path:NodePath
@onready var player = get_node(player_path)

func _process(_delta):
	transform = align_with_y(transform, player.position)

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform

