extends Control

onready var win_lose = $win_lose
onready var score = $score
onready var desc = $desc
onready var lobby_label = $lobby_time


var timer = null
var curr_time = 0
var wait_time = 5


func _ready():
	match Utils.game_scene_name:
		"prisoners_dilemma":
			result_1()
		"chicken":
			result_1()
		_:
			pass



func result_1():
	var p1_score = Utils.end_game_state.p1_score
	var p2_score = Utils.end_game_state.p2_score
	desc.hide()
	if get_tree().is_network_server():
		score.set_text("%d vs %d"%[p1_score,p2_score])
		if p1_score>p2_score:
			win_lose.set_text("You Win!")
		elif p1_score == p2_score:
			win_lose.set_text("Its A Tie!")
		else:
			win_lose.set_text("You Lose!")
	else:
		score.set_text("%d vs %d"%[p2_score,p1_score])
		if p2_score>p1_score:
			win_lose.set_text("You Win!")
		elif p1_score == p2_score:
			win_lose.set_text("Its A Tie!")
		else:
			win_lose.set_text("You Lose!")

	Utils.game_scene_name = ""
	Utils.end_game_state = null
	timer = Timer.new()
	timer.connect("timeout",self,"_on_timer_timeout") 
	timer.set_wait_time(1)
	timer.set_one_shot(false)
	add_child(timer) 
	timer.start() 


func _on_timer_timeout():
	curr_time += 1
	lobby_label.set_text("Lobby in %d..."%(wait_time-curr_time))
	if curr_time == wait_time:
		Transit.fade_scene("game_list")

