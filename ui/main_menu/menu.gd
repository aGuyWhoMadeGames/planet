extends Control

func _on_host_pressed():
	$Loading.show()
	$Main.hide()
	await get_tree().process_frame
	await get_tree().process_frame
	Multiplayer.host()
	get_tree().change_scene_to_file("res://main.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_join_menu_pressed():
	$Main.hide()
	$Join.show()
	if Multiplayer.get_child_count() == 0:
		Multiplayer.join()
		Multiplayer.get_child(0).server_list.connect(list_servers)
	else:
		Multiplayer.get_child(0).get_servers()


func _on_join_back_pressed():
	$Main.show()
	$Join.hide()

func list_servers(servers):
	var list:ItemList = $Join/Control/Control/ItemList
	list.clear()
	for id in servers:
		list.add_item(str(id))

func _on_item_list_item_activated(index):
	$Loading.show()
	$Join.hide()
	await get_tree().process_frame
	await get_tree().process_frame
	Multiplayer.get_child(0).join(int($Join/Control/Control/ItemList.get_item_text(index)))
	get_tree().change_scene_to_file("res://main.tscn")
