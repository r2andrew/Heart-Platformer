extends Node2D

@export var next_level: PackedScene

var level_time = 0.0
var start_level_msec = 0.0

@onready var level_completed = $CanvasLayer/LevelCompleted
@onready var start_in = %StartIn 
@onready var start_in_label = %StartInLabel
@onready var animation_player = $AnimationPlayer
@onready var level_time_label = %LevelTimeLabel

func _ready():
	if not next_level is PackedScene:
		level_completed.next_level_button.text = "View Score"
		next_level = load("res://victory_screen.tscn")
		
	RenderingServer.set_default_clear_color(Color.BLACK)
	Events.level_completed.connect(show_level_completed)
	start_in.visible = true
	
	get_tree().paused = true
	print(Events.just_restarted_r)
	if !Events.just_restarted_r:
		LevelTransition.fade_from_black()
		animation_player.play("countdown")
		await animation_player.animation_finished
	else: Events.just_restarted_r = false
	get_tree().paused = false
	start_in.visible = false
	start_level_msec = Time.get_ticks_msec()
	
func _process(delta):
	level_time = Time.get_ticks_msec() - start_level_msec
	level_time_label.text = str(level_time / 1000.0)
	
	if Input.is_action_just_pressed("restart"):
		Events.just_restarted_r = true
		get_tree().change_scene_to_file(scene_file_path)
	
func retry():
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_file(scene_file_path)
	
func go_to_next_level():
	if next_level is PackedScene:
		await LevelTransition.fade_to_black()
		get_tree().paused = false
		get_tree().change_scene_to_packed(next_level)
	
func show_level_completed():
	level_completed.show()
	level_completed.retry_button.grab_focus()
	get_tree().paused = true

func _on_level_completed_retry():
	retry()

func _on_level_completed_next_level():
	Events.append_level_time(level_time)
	go_to_next_level()
