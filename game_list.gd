extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if not get_tree().is_network_server():
		get_node("Label").text = "Server is selecting the game"


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
sync func goto_game(scene):
	Utils.goto_scene(scene)

func load_prisoners_dilemma():
	if get_tree().is_network_server():
		print("Netowrk Server")
		rpc("goto_game","prisoners_dilemma")

	#Utils.goto_scene("prisoners_dilemma")
	#rpc("Utils.goto_scene","prisoners_dilemma")
