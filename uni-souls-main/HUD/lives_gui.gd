extends CanvasLayer

func _process(delta: float) -> void:
	$Label.text = "Lives: " + str(Global.player_lives)
	
