extends Control

@export var key:InputEventAction


func _input(_event):
	if Input.is_action_just_pressed(key.action):
		visible = not visible
