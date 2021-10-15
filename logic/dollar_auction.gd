extends Control

var state = {
	wait_time = 20,
	curr_time = 0,
	
	curr_round = 1,
	p1_bid = 0,
	p2_bid = 0,
}


onready var desc = $payoff_matix/desc
onready var round_label = $round
onready var timer = $timer
onready var last_play = $last_play
onready var score = $score
onready var head_button = $head
onready var tail_button = $tail
onready var forefeit = $forefit

func _ready():
	self.add_child(Utils.button_click_sound)
	for button in $bids.get_children():
		button.connect("pressed", self, "on_bid_button_pressed", [button])
	timer = Timer.new()
	timer.connect("timeout",self,"_on_timer_timeout") 
	timer.set_wait_time(1)
	timer.set_one_shot(false)
	add_child(timer) 
	timer.start() 
	var bid = 0
	for child in $bids.get_children():
		child.set_text("$%0.2f"%bid)
		bid+=0.05
	


func _on_timer_timeout():
	state.curr_time += 1
	$timer.set_text("%d "%(state.wait_time-state.curr_time))
	if state.curr_time == state.wait_time:
		if get_tree().is_network_server():
			rpc("goto_scene","result")



func update_screen():
	print("Update Screen")
	if get_tree().is_network_server():
		if state.p1_bid>state.p2_bid:
			forefeit.set_disabled(true)
		else:
			forefeit.set_disabled(false)
		last_play.set_text("Bids:  %0.2f$ (you) vs %0.2f$ (opp.)"%[state.p1_bid,state.p2_bid])
	else:
		if state.p2_bid>state.p1_bid:
			forefeit.set_disabled(true)
		else:
			forefeit.set_disabled(false)
		last_play.set_text("Bids:  %0.2f$ (you) vs %0.2f$ (opp.)"%[state.p2_bid,state.p1_bid])
	Transit.fade_scene()
	var bid = max(state.p1_bid,state.p2_bid)+0.05
	for child in $bids.get_children():
		child.set_text("$%0.2f"%bid)
		bid+=0.05
	
	
func on_bid_button_pressed(button):
	Utils.play_button_sound()
	print(button.text.substr(1).to_float())
	set_bid(button.text.substr(1).to_float())
	button.release_focus()

func set_bid(bid):
	if get_tree().is_network_server():
		state.p1_bid = bid
	else:
		state.p2_bid = bid
	state.curr_time = 0
	rpc("sync_state",state)


remotesync func goto_scene(scene):
	Utils.end_game_state = state
	Transit.fade_scene(scene)


remotesync func sync_state(new_state):
	print("sync state")
	state = new_state
	update_screen()

func _on_forefit_pressed():
	Utils.play_button_sound()
	rpc("goto_scene","result")
