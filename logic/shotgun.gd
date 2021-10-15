extends Control

var state = {
	wait_time = 20,
	curr_time = 0,
	curr_round = 1,
	
	p1_bullets = 0,
	p2_bullets = 0,
	
	p1_move = -1,
	p2_move =-1
	}


onready var round_label = $round
onready var timer = $timer
onready var last_play = $last_play
onready var score = $score
onready var shield_button = $shield
onready var reload_button = $reload
onready var shoot_button = $shoot


func _get_move_name(var move):
	if move<0:
		return ""
	elif move==0:
		return "Reload"
	elif move==1:
		return "Shield"
	else:
		return "Shoot"


func _ready():
	timer = Timer.new()
	timer.connect("timeout",self,"_on_timer_timeout") 
	timer.set_wait_time(1) #value is in seconds: 600 seconds = 10 minutes
	timer.set_one_shot(false)
	add_child(timer) 
	timer.start()
	shoot_button.set_disabled(true)
	self.add_child(Utils.button_click_sound)


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
	shield_button.release_focus()
	reload_button.release_focus()
	shoot_button.release_focus()
	shield_button.set_disabled(false)
	reload_button.set_disabled(false)
	
	round_label.set_text("Round %d "%state.curr_round)
	if get_tree().is_network_server():
		if (state.p1_bullets<1):
			shoot_button.set_disabled(true)
		else:
			shoot_button.set_disabled(false)
		
		score.set_text(" Bullets\n %d vs %d "%[state.p1_bullets,state.p2_bullets])
		last_play.set_text("Last play: %s, %s"%[
			_get_move_name(state.p1_move),
			_get_move_name(state.p2_move)
			])
	else:
		if (state.p2_bullets<1):
			shoot_button.set_disabled(true)
		else:
			shoot_button.set_disabled(false)

		score.set_text(" Bullets\n %d vs %d "%[state.p2_bullets,state.p1_bullets])
		last_play.set_text("Last play: %s, %s"%[
			_get_move_name(state.p2_move),
			_get_move_name(state.p1_move)
			])
	
	if is_end():
		goto_scene("result")
	else:
		state.p1_move = -1
		state.p2_move = -1
		Transit.fade_scene()


func is_end():
	if (state.p1_bullets==5 or state.p2_bullets==5):
		return true
	elif (state.p1_move==2 and state.p2_move!=0) or (state.p2_move==2 and state.p1_move!=0):
		return true
	else:
		return false


func update_state():
	print("Update state")
	print("p1: %s, p2: %s"%[state.p1_move,state.p2_move])
	if (state.p1_move<0 or state.p2_move<0):
		return
	
	state.curr_round+=1
	state.curr_time = 0 
	
	if state.p1_move==2:
		state.p1_bullets-=1
	if state.p2_move ==2:
		state.p2_bullets-=1
	if state.p1_move == 1:
		state.p1_bullets+=1
	if state.p2_move == 1:
		state.p2_bullets+=1
	update_screen()


sync func goto_scene(scene):
	Utils.end_game_state = state
	Transit.fade_scene(scene)


remotesync func sync_state(new_state):
	print("sync state")
	state = new_state
	update_state()


func _on_shield_pressed():
	Utils.play_button_sound()
	if get_tree().is_network_server():
		if(state.p1_move>=0):
			return
		state.p1_move = 0
	else:
		if(state.p2_move>=0):
			return
		state.p2_move = 0
	
	#confess_button.set_disabled(true)
	reload_button.set_disabled(true)
	shoot_button.set_disabled(true)
	rpc("sync_state",state)


func _on_reload_pressed():
	Utils.play_button_sound()
	if get_tree().is_network_server():
		if(state.p1_move>=0):
			return
		state.p1_move = 1
	else:
		if(state.p2_move>=0):
			return
		state.p2_move = 1
	shoot_button.set_disabled(true)
	shield_button.set_disabled(true)
	rpc("sync_state",state)


func _on_shoot_pressed():
	Utils.play_button_sound()
	if get_tree().is_network_server():
		if (state.p1_bullets<1 or state.p1_move>=0):
			return
		state.p1_move = 2
	else:
		if (state.p2_bullets<1 or state.p2_move>=0):
			return
		state.p2_move = 2
		
	shield_button.set_disabled(true)
	reload_button.set_disabled(true)
	rpc("sync_state",state)
