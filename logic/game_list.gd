extends Control

onready var message_label = $message

func _ready():
	self.add_child(Utils.button_click_sound)
	if not get_tree().is_network_server():
		var grid_cont  = $PanelContainer/ScrollContainer/GridContainer
		for node in grid_cont.get_children():
			node.set_disabled(true)
		message_label.set_text("Server is selecting the game")


sync func goto_game(scene):
	print(scene)
	Utils.game_scene_name = scene
	Transit.fade_scene("load_screen")


remotesync func signal_end_game():
	if not get_tree().is_network_server():
		Utils.welcome_scene._end_game("Server Disconnected!")
	else:
		Utils.welcome_scene._end_game("")


func _on_home_pressed():
	Utils.play_button_sound()
	rpc("signal_end_game")


func _on_prisoners_dillema_pressed():
	Utils.play_button_sound()
	if get_tree().is_network_server():
		rpc("goto_game","prisoners_dilemma")


func _on_game_of_chicken_pressed():
	Utils.play_button_sound()
	if get_tree().is_network_server():
		rpc("goto_game","chicken")


func _on_shotgun_pressed():
	Utils.play_button_sound()
	if get_tree().is_network_server():
		rpc("goto_game","shotgun")


func _on_centipede_pressed():
	Utils.play_button_sound()
	if get_tree().is_network_server():
		rpc("goto_game","centipede")


func _on_dollar_auction_pressed():
	Utils.play_button_sound()
	if get_tree().is_network_server():
		rpc("goto_game","dollar_auction")


func _on_matching_pennies_pressed():
	Utils.play_button_sound()
	if get_tree().is_network_server():
		rpc("goto_game","matching_pennies")
