extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

sync func goto_scene(scene):
	Utils.goto_scene(scene)

func _on_loby_pressed():
	rpc("goto_scene","game_list")
