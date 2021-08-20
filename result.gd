extends Control

onready var home_label = $home_time
onready var win_lose = $win_lose
onready var score = $score
var timer = null
var curr_time = 0
var wait_time = 5


func _ready():
	print("Util Score: %d"%Utils.p1_score)
	if get_tree().is_network_server():
		score.set_text("%d vs %d"%[Utils.p1_score,Utils.p2_score])
		if Utils.p1_score>Utils.p2_score:
			win_lose.set_text("You Win!")
		elif Utils.p1_score == Utils.p2_score:
			win_lose.set_text("Its A Tie!")
		else:
			win_lose.set_text("You Lose!")
	else:
		score.set_text("%d vs %d"%[Utils.p2_score,Utils.p1_score])
		if Utils.p2_score>Utils.p1_score:
			win_lose.set_text("You Win!")
		elif Utils.p1_score == Utils.p2_score:
			win_lose.set_text("Its A Tie!")
		else:
			win_lose.set_text("You Lose!")
	Utils.p1_score = 0
	Utils.p2_score = 0
	timer = Timer.new()
	timer.connect("timeout",self,"_on_timer_timeout") 
	timer.set_wait_time(1) #value is in seconds: 600 seconds = 10 minutes
	timer.set_one_shot(false)
	add_child(timer) 
	timer.start() 

func _on_timer_timeout():
	curr_time += 1
	home_label.set_text("Lobby in %d..."%(wait_time-curr_time))
	if curr_time == wait_time:
		Transit.fade_scene("game_list")
