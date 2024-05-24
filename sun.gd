@tool
extends DirectionalLight3D

func _process(_delta):
	RenderingServer.global_shader_parameter_set("SUN_DIR",transform.basis.z)
