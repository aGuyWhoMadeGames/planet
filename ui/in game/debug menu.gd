extends Label

var wireframe = false

var template = """
{cpu}
{gpu}
Fps: {fps}
Triangles: {tris}
Resolution: {xres}x{yres}
Memory:{mem}Mb
"""

func _process(_delta):
	text = template.format({
		"cpu":OS.get_processor_name(),
		"gpu":RenderingServer.get_video_adapter_name(),
		"fps":Engine.get_frames_per_second(),
		"tris":RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME),
		"xres":get_viewport().size.x,
		"yres":get_viewport().size.y,
		"mem":round((OS.get_static_memory_usage())*0.000001)
	})

func _input(_event):
	if Input.is_action_just_pressed("toggle_wireframe"):
		if wireframe:
			RenderingServer.viewport_set_debug_draw(get_viewport().get_viewport_rid(),RenderingServer.VIEWPORT_DEBUG_DRAW_DISABLED)
		else:
			RenderingServer.viewport_set_debug_draw(get_viewport().get_viewport_rid(),RenderingServer.VIEWPORT_DEBUG_DRAW_WIREFRAME)
		wireframe = not wireframe
