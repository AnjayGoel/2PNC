extends Control

onready var message_label = $message

func _ready():
	if not get_tree().is_network_server():
		message_label.set_text("Server is selecting the game")


sync func goto_game(scene):
	print(scene)
	Utils.game_scene_name = scene
	Transit.fade_scene("load_screen")


func load_prisoners_dilemma():
	if get_tree().is_network_server():
		rpc("goto_game","prisoners_dilemma")


func _on_game_of_chicken_pressed():
	if get_tree().is_network_server():
		rpc("goto_game","chicken")


remotesync func signal_end_game():
	Utils.welcome_scene._end_game("")


func _on_home_pressed():
	rpc("signal_end_game")



