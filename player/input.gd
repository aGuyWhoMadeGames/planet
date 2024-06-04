extends Node


@export var movement2:Vector2
@export var jump:bool
@export var click:float

@onready var player = $'..'

func _process(_delta):
	if multiplayer.get_unique_id()==get_multiplayer_authority():
		update_inputs()

func update_inputs():
	movement2 = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	if Input.is_action_pressed("sprint"):
		movement2 *= player.run_speed
	else:
		movement2 *= player.walk_speed
	
	movement2 *=  int($"../Camera3D".current)
	
	jump = Input.is_action_pressed("jump")
	
	click = Input.get_axis("left_click","right_click")
