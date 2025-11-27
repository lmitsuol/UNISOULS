extends VideoStreamPlayer

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		skip_cutscene()

func _on_finished():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func skip_cutscene():
	stop()
	get_tree().change_scene_to_file("res://scenes/game.tscn")
