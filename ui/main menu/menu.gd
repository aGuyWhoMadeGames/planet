extends Control




func _on_host_pressed():
	$Loading.show()
	$Main.hide()
	await get_tree().process_frame
	await get_tree().process_frame
	GlobalData.data = {
		"server":true
	}
	GlobalData.use_data = true
	get_tree().change_scene_to_file("res://main.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_join_menu_pressed():
	$Main.hide()
	$Join.show()


func _on_join_back_pressed():
	$Main.show()
	$Join.hide()

func _on_join_pressed():
	_on_ip_text_submitted($Join/Control/Control/ip.text)


func _on_ip_text_submitted(text):
	$Loading.show()
	$Join.hide()
	await get_tree().process_frame
	await get_tree().process_frame
	GlobalData.data = {
		"server":false,
		"ip":text
	}
	GlobalData.use_data = true
	get_tree().change_scene_to_file("res://main.tscn")
