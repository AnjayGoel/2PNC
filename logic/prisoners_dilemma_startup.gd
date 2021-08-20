extends Control


onready var start_label = $start_label
var timer = null
var curr_time = 0
var wait_time = 10


func _ready():
   timer = Timer.new()
   timer.connect("timeout",self,"_on_timer_timeout") 
   timer.set_wait_time(1) #value is in seconds: 600 seconds = 10 minutes
   timer.set_one_shot(false)
   add_child(timer) 
   timer.start() 

func _on_timer_timeout():
	curr_time += 1
	start_label.set_text("Starting in %d..."%(wait_time-curr_time))
	if curr_time == wait_time:
		Transit.fade_scene("prisoners_dilemma")
