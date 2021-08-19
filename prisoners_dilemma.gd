extends Control


const wait_time = 20;
var curr_time = 0; 

var curr_round = 1
var p1_score = 0
var p2_score = 0
var p1_last_score = 0
var p2_last_score = 0

var p1_move = -1
var p2_move =-1




onready var round_label = $round
onready var timer = $timer
onready var you = $you
onready var opp = $opp



func _ready():
   timer = Timer.new()
   timer.connect("timeout",self,"_on_timer_timeout") 
   timer.set_wait_time(1) #value is in seconds: 600 seconds = 10 minutes
   timer.set_one_shot(false)
   add_child(timer) 
   timer.start() 


func _on_timer_timeout():
	curr_time += 1
	$timer.set_text("%d"%(wait_time-curr_time))
	if curr_time == wait_time:
		curr_time = 0
		if get_tree().is_network_server():
			if (p1_move<0):
				p1_move = 0
			if (p2_move<0):
				p2_move = 0
			rpc("sync_state",p1_move,p2_move)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func update_screen():
	print("Update Screen called")
	round_label.set_text("%d"%curr_round)
	if get_tree().is_network_server():
		you.set_text("%d/%d"%[p1_last_score,p1_score])
		opp.set_text("%d/%d"%[p2_last_score,p2_score])
	else:
		opp.set_text("%d/%d"%[p1_last_score,p1_score])
		you.set_text("%d/%d"%[p2_last_score,p2_score])

func update_state():
	print("Update state called")
	print("p1: %s, p2: %s"%[p1_move,p2_move])
	if (p1_move>=0 and p2_move>=0):
		#Confess,Confess
		if(p1_move==0 and p2_move==0):
			p1_score -=5
			p2_score -=5
			p1_last_score = -5
			p2_last_score = -5
		#Confess,Deny
		if(p1_move==0 and p2_move==1):
			p1_score -=0
			p2_score -=10
			p1_last_score = 0
			p2_score = -10
		#Deny,Confess
		if(p1_move==1 and p2_move==0):
			p1_score -=10
			p2_score -=0
			p1_last_score = -10
			p2_score = 0
		#Deny,Deny
		if(p1_move==1 and p2_move==1):
			p1_score -=1
			p2_score -=1
			p1_last_score = -1
			p2_score = -1
		
		p1_move = -1
		p2_move = -1
		curr_round+=1
		curr_time = 0
		update_screen()


sync func goto_scene(scene):
	Utils.goto_scene(scene)


func _on_loby_pressed():
	rpc("goto_scene","game_list")


remotesync func sync_state(p1,p2):
	print("sync state")
	p1_move = p1
	p2_move = p2
	update_state()


func _on_confess_pressed():
	
	if get_tree().is_network_server():
		print("server")
		if(p1_move>=0):
			return
		p1_move = 0
	else:
		print("Not server")
		if(p2_move>=0):
			return
		p2_move = 0
	
	rpc("sync_state",p1_move,p2_move)
	print("confess")


func _on_deny_pressed():
	if get_tree().is_network_server():
		print("server")
		if(p1_move>=0):
			return
		p1_move = 1
	else:
		print("Not server")
		if(p2_move>=0):
			return
		p2_move = 1

	rpc("sync_state",p1_move,p2_move)
	print("deny")
