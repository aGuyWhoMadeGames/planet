extends Control


var node:Node

func _on_client_pressed():
	Multiplayer.join()
	Multiplayer.get_child(0).server_list.connect(list_servers)
	#get_tree().change_scene_to_file("res://main.tscn")
	$VBoxContainer.hide()


func _on_server_pressed():
	Multiplayer.host()
	get_tree().change_scene_to_file("res://main.tscn")
	$VBoxContainer.hide()


func _on_signal_pressed():
	node = load("res://multiplayer/signaling.gd").new()
	add_child(node)
	$VBoxContainer.hide()

func list_servers(servers):
	var list:ItemList = $ItemList
	list.clear()
	for id in servers:
		list.add_item(str(id))
	list.show()


func _on_item_list_item_activated(index):
	Multiplayer.get_child(0).join(int($ItemList.get_item_text(index)))
	get_tree().change_scene_to_file("res://main.tscn")
