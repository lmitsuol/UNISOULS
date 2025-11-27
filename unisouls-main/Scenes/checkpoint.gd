extends Area2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var campfire_sound = $campfire

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	monitoring = true
	
	animated_sprite.play("normal")

func _on_body_entered(body):
	if animated_sprite.animation == "fire":
		return
		
	if body.is_in_group("Player"):
		body.save_checkpoint(global_position)
		print("CHECKPOINT SALVO EM:", global_position)
		
		animated_sprite.play("fire")
		campfire_sound.play()
