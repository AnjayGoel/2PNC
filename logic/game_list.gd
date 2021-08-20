extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
onready var message_label = $message
func _ready():
	if not get_tree().is_network_server():
		message_label.set_text("Server is selecting the game")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
sync func goto_game(scene):
	Transit.fade_scene(scene)

func load_prisoners_dilemma():
	if get_tree().is_network_server():
		print("Netowrk Server")
		rpc("goto_game","prisoners_dilemma_startup")

	#Utils.goto_scene("prisoners_dilemma")
	#rpc("Utils.goto_scene","prisoners_dilemma")

remotesync func signal_end_game():
	Utils.welcome_scene._end_game("")

func _on_home_pressed():
	rpc("signal_end_game")
