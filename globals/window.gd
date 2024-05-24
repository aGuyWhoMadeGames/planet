extends Node


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(_event):
	if Input.is_action_just_pressed("fullscreen"):
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (not ((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))) else Window.MODE_WINDOWED
	if Input.is_action_just_pressed("screenshot"):
		var capture = get_viewport().get_texture().get_image()
		var _time = Time.get_datetime_string_from_system(false,true).replace(':','-')
		var filename = "user://Screenshot-{0}.png".format({"0":_time})
		capture.save_png(filename)
