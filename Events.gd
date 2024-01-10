extends Node

@export var times = []
@export var just_restarted_r = false
var levelIndex = 0

signal level_completed

func _ready():
	times.resize(3)
	times.fill(0)
	
func reset_levelIndex():
	levelIndex = 0

func playCollectSound():
	$collectSound.play()
	
func append_level_time(level_time):
	times[levelIndex] = level_time / 1000.0
	
	levelIndex += 1
	
	
	
