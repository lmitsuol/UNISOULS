extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Music.play_music("floresta")
	Global.set_current_area("A Sala do Golem")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
