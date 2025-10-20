extends Control

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var options: Panel = $Options

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		toggle_pause()
		
func toggle_pause() -> void:
	get_tree().paused = !get_tree().paused
	self.visible = get_tree().paused

func _ready():
	self.visible = false
	main_buttons.visible = true
	options.visible = false

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_options_pressed() -> void:
	print("Options pressed")
	main_buttons.visible = false
	options.visible = true

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_back_options_pressed() -> void:
	main_buttons.visible = true
	options.visible = false

func _on_continue_pressed() -> void:
	toggle_pause()
	
