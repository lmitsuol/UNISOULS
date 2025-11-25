extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Music.play_music("caverna")
	Global.set_current_area("A Caverna")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_interact_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.die()

func _on_interact_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.die()
