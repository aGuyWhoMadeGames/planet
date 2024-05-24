extends Control

@export var key:InputEventAction


func _process(_delta):
	if Input.is_action_just_pressed(key.action):
		visible = not visible
