extends Control

var state = {
	wait_time = 20,
	curr_time = 0,

	curr_round = 1,
	p1_score = 0,
	p2_score = 0,
	p1_last_score = 0,
	p2_last_score = 0,

	p1_move = -1,
	p2_move =-1,
	p1_label = "",
	p2_label = "",
	}


onready var round_label = $round
onready var timer = $timer
onready var last_play = $last_play
onready var score = $score
onready var confess_button = $confess
onready var deny_button = $deny


func _ready():
   timer = Timer.new()
   timer.connect("timeout",self,"_on_timer_timeout") 
   timer.set_wait_time(1) #value is in seconds: 600 seconds = 10 minutes
   timer.set_one_shot(false)
   add_child(timer) 
   timer.start() 


func _on_timer_timeout():
	state.curr_time += 1
	$timer.set_text("%d "%(state.wait_time-state.curr_time))
	if state.curr_time == state.wait_time:
		state.curr_time = 0
		if get_tree().is_network_server():
			if (state.p1_move<0):
				state.p1_move = 0
			if (state.p2_move<0):
				state.p2_move = 0
			rpc("sync_state",state)


func update_screen():
	print("Update Screen")
	confess_button.release_focus()
	deny_button.release_focus()
	confess_button.set_disabled(false)
	deny_button.set_disabled(false)
	round_label.set_text("%d "%state.curr_round)
	if get_tree().is_network_server():
		score.set_text(" %d vs %d "%[state.p1_score,state.p2_score])
		last_play.set_text("Last play: %s, %s"%[state.p1_label,state.p2_label])
	else:
		score.set_text(" %d vs %d "%[state.p2_score,state.p1_score])
		last_play.set_text("Last play: %s, %s"%[state.p2_label,state.p1_label])
	
	Transit.fade_scene()


func update_state():
	print("Update state")
	print("p1: %s, p2: %s"%[state.p1_move,state.p2_move])
	if (state.p1_move>=0 and state.p2_move>=0):
		if (state.p1_move==0):
			state.p1_label = "Confess"
		else:
			state.p1_label = "Deny"
		if(state.p2_move==0):
			state.p2_label = "Confess"
		else:
			state.p2_label = "Deny"
		#Confess,Confess
		if(state.p1_move==0 and state.p2_move==0):
			state.p1_score -=5
			state.p2_score -=5
			state.p1_last_score = -5
			state.p2_last_score = -5
		#Confess,Deny
		if(state.p1_move==0 and state.p2_move==1):
			state.p1_score -=0
			state.p2_score -=10
			state.p1_last_score = 0
			state.p2_last_score = -10
		#Deny,Confess
		if(state.p1_move==1 and state.p2_move==0):
			state.p1_score -=10
			state.p2_score -=0
			state.p1_last_score = -10
			state.p2_last_score = 0
		#Deny,Deny
		if(state.p1_move==1 and state.p2_move==1):
			state.p1_score -=1
			state.p2_score -=1
			state.p1_last_score = -1
			state.p2_last_score = -1
		
		state.p1_move = -1
		state.p2_move = -1
		state.curr_round+=1
		state.curr_time = 0
		update_screen()


sync func goto_scene(scene):
	Utils.end_game_state = state
	Transit.fade_scene(scene)


func _on_loby_pressed():
	rpc("goto_scene","result")


remotesync func sync_state(new_state):
	print("sync state")
	state = new_state
	update_state()


func _on_confess_pressed():
	#confess_button.set_disabled(true)
	deny_button.set_disabled(true)
	if get_tree().is_network_server():
		print("Deny server")
		if(state.p1_move>=0):
			return
		state.p1_move = 0
	else:
		print("Deny Not server")
		if(state.p2_move>=0):
			return
		state.p2_move = 0
	
	rpc("sync_state",state)


func _on_deny_pressed():
	confess_button.set_disabled(true)
	#deny_button.set_disabled(true)
	if get_tree().is_network_server():
		print("Deny server")
		if(state.p1_move>=0):
			return
		state.p1_move = 1
	else:
		print("Deny Not server")
		if(state.p2_move>=0):
			return
		state.p2_move = 1

	rpc("sync_state",state)

