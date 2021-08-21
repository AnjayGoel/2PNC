extends Control

var state = {
	wait_time = 20,
	curr_time = 0,

	curr_round = 1,
	turn = 0,
	p1_score = 2,
	p2_score = 0,
}


onready var round_label = $round
onready var timer = $timer
onready var turn = $turn
onready var end_button = $end_here
onready var continue_button = $continue
onready var current_payoff = $payoff_matix/GridContainer/curr_payoff
onready var next_payoff = $payoff_matix/GridContainer/next_payoff
onready var ntn_payoff = $payoff_matix/GridContainer/next_to_next_payoff


func _ready():
	timer = Timer.new()
	timer.connect("timeout",self,"_on_timer_timeout") 
	timer.set_wait_time(1)
	timer.set_one_shot(false)
	add_child(timer) 
	timer.start() 
	update_screen()
	if not get_tree().is_network_server():
		continue_button.set_disabled(true)
		end_button.set_disabled(true)


func _on_timer_timeout():
	state.curr_time += 1
	$timer.set_text("%d "%(state.wait_time-state.curr_time))
	if state.curr_time == state.wait_time:
		state.curr_time = 0
		if ((get_tree().is_network_server() and state.turn == 0) or 
		(not get_tree().is_network_server() and state.turn == 1)):
			update_state()
			rpc("sync_state",state)



func update_state():
	if state.curr_round==10:
		state.p1_score = 10
		state.p2_score = 10

	elif state.turn == 0:
		state.p1_score -=1
		state.p2_score+=3
	elif state.turn == 1:
		state.p1_score +=3
		state.p2_score -=1
		
	state.turn = 1-state.turn
	state.curr_round+=1
	

func update_screen():
	print("Update Screen")
	if state.curr_round>10:
		rpc("goto_scene","result")
	continue_button.release_focus()
	end_button.release_focus()
	continue_button.set_disabled(true)
	end_button.set_disabled(true)
	round_label.set_text("%d "%state.curr_round)
	
	var p1 = state.p1_score
	var p2 = state.p2_score
	
	if get_tree().is_network_server():
		if state.turn == 0:
			turn.set_text("Your Turn!")
			continue_button.set_disabled(false)
			end_button.set_disabled(false)
			current_payoff.set_text("%d, %d"%[p1, p2])
			next_payoff.set_text("%d, %d"%[p1-1, p2+3])
			ntn_payoff.set_text("%d, %d"%[p1+2, p2+2])
		else:
			turn.set_text("Opponents Turn!")
			current_payoff.set_text("%d, %d"%[p1, p2])
			next_payoff.set_text("%d, %d"%[p1+3, p2-1])
			ntn_payoff.set_text("%d, %d"%[p1+2, p2+2])
	else:
		if state.turn == 1:
			turn.set_text("Your Turn!")
			continue_button.set_disabled(false)
			end_button.set_disabled(false)
			current_payoff.set_text("%d, %d"%[p2, p1])
			next_payoff.set_text("%d, %d"%[p2-1, p1+3])
			ntn_payoff.set_text("%d, %d"%[p2+2, p1+2])
		else:
			turn.set_text("Opponents Turn!")
			current_payoff.set_text("%d, %d"%[p2, p1])
			next_payoff.set_text("%d, %d"%[p2+3, p1-1])
			ntn_payoff.set_text("%d, %d"%[p2+2, p1+2])
			
	if state.curr_round == 10:
		ntn_payoff.set_text("-, -")
		next_payoff.set_text("10, 10")
	if state.curr_round == 9:
		ntn_payoff.set_text("10, 10")
	
	Transit.fade_scene()


sync func goto_scene(scene):
	Utils.end_game_state = state
	Transit.fade_scene(scene)


remotesync func sync_state(new_state):
	print("sync state")
	state = new_state
	update_screen()


func _on_continue_pressed():
	if ((get_tree().is_network_server() and state.turn == 1)
	 or (not get_tree().is_network_server() and state.turn == 0)):
		return

	update_state()
	rpc("sync_state",state)


func _on_end_here_pressed():
	if ((get_tree().is_network_server() and state.turn == 1)
	 or (not get_tree().is_network_server() and state.turn ==0)):
		return
	rpc("goto_scene","result")

