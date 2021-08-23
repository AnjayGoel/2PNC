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
		"shotgun":
			result_shotgun()
		"centipede":
			result_1()
		"matching_pennies":
			result_1()
		"dollar_auction":
			result_auction()
		_:
			pass
	Utils.game_scene_name = ""
	Utils.end_game_state = null
	timer = Timer.new()
	timer.connect("timeout",self,"_on_timer_timeout") 
	timer.set_wait_time(1)
	timer.set_one_shot(false)
	add_child(timer) 
	timer.start() 


func result_auction():
	desc.hide()
	print("%0.2f"%Utils.end_game_state.p1_bid)
	var p1_payoff = -Utils.end_game_state.p1_bid
	var p2_payoff =  -Utils.end_game_state.p2_bid
	if (Utils.end_game_state.p1_bid>Utils.end_game_state.p2_bid):
		p1_payoff+=1
	elif (Utils.end_game_state.p1_bid<Utils.end_game_state.p2_bid):
		p2_payoff+=1
	print("$%0.2f vs $%0.2f"%[p1_payoff,p2_payoff])
	if p1_payoff>p2_payoff:
		if get_tree().is_network_server():
			win_lose.set_text("You Win!")
			score.set_text("$%0.2f vs $%0.2f"%[p1_payoff,p2_payoff])
		else:
			win_lose.set_text("You Lose!")
			score.set_text("$%0.2f vs $%0.2f"%[p2_payoff,p1_payoff])
	elif p1_payoff == p2_payoff:
		win_lose.set_text("Its a Tie!")
		score.set_text("$%0.2f vs $%0.2f"%[p2_payoff,p1_payoff])
	else:
		if get_tree().is_network_server():
			win_lose.set_text("You Lose!")
			score.set_text("$%0.2f vs $%0.2f"%[p1_payoff,p2_payoff])
		else:
			win_lose.set_text("You Win!")
			score.set_text("$%0.2f vs $%0.2f"%[p2_payoff,p1_payoff])


func result_1():
	print(Utils.game_scene_name)
	var p1_score = Utils.end_game_state.p1_score
	var p2_score = Utils.end_game_state.p2_score
	print("%d--%d"%[p1_score,p2_score])
	desc.hide()
	if get_tree().is_network_server():
		print("server")
		score.set_text("%d vs %d"%[p1_score,p2_score])
		print(score.text)
		if p1_score>p2_score:
			print("win!!!!")
			win_lose.set_text("You Win!")
		elif p1_score == p2_score:
			print("Tie")
			win_lose.set_text("Its A Tie!")
		else:
			win_lose.set_text("You Lose!")
	else:
		print("Client")
		score.set_text("%d vs %d"%[p2_score,p1_score])
		if p2_score>p1_score:
			win_lose.set_text("You Win!")
		elif p1_score == p2_score:
			win_lose.set_text("Its A Tie!")
		else:
			win_lose.set_text("You Lose!")



func result_shotgun():
	var state = Utils.end_game_state
	score.set_text("")
	if get_tree().is_network_server():
		if state.p1_move==2:
			if state.p2_move==2:
				win_lose.set_text("Its a Tie")
				desc.set_text("You both shot simultaneously")
			else:
				win_lose.set_text("You Win!")
				desc.set_text("You shot your opponent first")
		elif state.p1_bullets==5:
			if state.p2_bullets==5:
				win_lose.set_text("Its a Tie")
				desc.set_text("You both have 5 bullets")
			else:
				win_lose.set_text("You Win!")
				desc.set_text("You have 5 bullets")
		else:
			win_lose.set_text("You Lose!")
			if state.p2_move==2:
				desc.set_text("Opponent shot you")
			else:
				desc.set_text("Opponent has 5 bullets")
	else:
		if state.p2_move==2:
			if state.p1_move==2:
				win_lose.set_text("Its a Tie")
				desc.set_text("You both shot simultaneously")
			else:
				win_lose.set_text("You Win!")
				desc.set_text("You shot your opponent first")
		elif state.p2_bullets==5:
			if state.p1_bullets==5:
				win_lose.set_text("Its a Tie")
				desc.set_text("You both have 5 bullets")
			else:
				win_lose.set_text("You Win!")
				desc.set_text("You have 5 bullets")
		else:
			win_lose.set_text("You Lose!")
			if state.p1_move==2:
				desc.set_text("Opponent shot you")
			else:
				desc.set_text("Opponent has 5 bullets")

func _on_timer_timeout():
	curr_time += 1
	lobby_label.set_text("Lobby in %d..."%(wait_time-curr_time))
	if curr_time == wait_time:
		Transit.fade_scene("game_list")

