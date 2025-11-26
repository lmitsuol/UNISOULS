extends Area2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	monitoring = true

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.save_checkpoint(global_position)
		print("CHECKPOINT SALVO EM:", global_position)
