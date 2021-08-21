extends Control

onready var start_label = $start_label
onready var desc = $ScrollContainer/desc
onready var title = $title

var timer = null
var curr_time = 0
var wait_time = 2


func _ready():
	match Utils.game_scene_name:
		"prisoners_dilemma":
			title.set_text("Prisoners Dilemma")
			desc.set_text(
				"""
				You and your friend are suspected of committing a robbery 
				together. Both of you are isolated and urged to confess. If you 
				both confess, both go to jail for five years. If neither of you 
				confesses, both go to jail for one year and if one of you 
				confesses while the other does not, confessor goes free while 
				the silent person goes to jail for 10  years.
				"""
				)

		"chicken":
			title.set_text("Chicken")
			desc.set_text(
				"""
				You and your friend are both headed for a single-lane bridge 
				from opposite directions. If neither of you swerves (changes 
				direction), the result is a deadly collision. If you both 
				swerves, its a tie. However if you swerve and your friend does 
				not, he wins and you are a chicken. Similarly, if your 
				friend swerves and you don't, you win and your friend 
				is called a chicken. """
				)

		"shotgun":
			title.set_text("Shotgun")
			desc.set_text(
				"""
				Reload, Shield or Shoot. First one to get shot while other is 
				reloading loses.  Incase both shoot simultaneously, its a tie. 
				Else the first person to reach 5 bullets wins.
				"""
			)
		"centipede":
			title.set_text("Centipede")
			desc.set_text(
				"""
				Sequential game where you chose to take the payoff or continue 
				for a greater reward in next chance. Game ends in a finite 
				number or rounds.
				"""
			)
		_:
			pass
	
	timer = Timer.new()
	timer.connect("timeout",self,"_on_timer_timeout") 
	timer.set_wait_time(1)
	timer.set_one_shot(false)
	add_child(timer) 
	timer.start() 

func _on_timer_timeout():
	curr_time += 1
	start_label.set_text("Starting in %d..."%(wait_time-curr_time))
	if curr_time == wait_time:
		Transit.fade_scene(Utils.game_scene_name)
