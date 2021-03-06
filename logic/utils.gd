extends Node


var current_scene = null
var lobby_scene = null
var welcome_scene = null

var game_scene_name = ""
var end_game_state = null
var button_click_sound = null
var ui_sound = true
var bg_music = true


func _ready():
	button_click_sound = AudioStreamPlayer.new();
	button_click_sound.stream = load("res://assets/sounds/button_click.mp3")
	print("sound loaded")
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)


func play_button_sound():
	if ui_sound:
		button_click_sound.play()


func get_ip():
	var ip = ""
	for address in IP.get_local_addresses():
		if (address.split('.')[0] == "192"):
			ip=address
	return ip


func get_scene_path(scene):
	return "res://scenes/%s.tscn"%scene


func deferred_goto_scene(scene,hide=false):
	print("scene: %s"%scene)
	if hide:
		current_scene.hide()
	else:
		current_scene.free()
	var s = ResourceLoader.load(get_scene_path(scene))
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)


remote func goto_scene(scene):
	call_deferred("deferred_goto_scene", scene)


remote func add_scene(scene):
	call_deferred("deferred_goto_scene", scene,true)


func hide():
	pass
