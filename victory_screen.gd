extends CenterContainer

@onready var menu_button = %MenuButton
@onready var label = $VBoxContainer/Label
# Called when the node enters the scene tree for the first time.
func _ready():
	LevelTransition.fade_from_black()
	menu_button.grab_focus()
	
	var final_results = Events.times
	
	var score = int(10000/sum_array(final_results))
	
	label.text = 'Level 1: {} \nLevel 2: {}\nLevel 3: {}\nFinal Score: {}'.format([final_results[0], final_results[1], final_results[2], score], "{}");

func _on_menu_button_pressed():
	Events.reset_levelIndex()
	get_tree().change_scene_to_file("res://start_menu.tscn")
	
func sum_array(array):
	var sum = 0.0
	for element in array:
		sum += element
	return sum
