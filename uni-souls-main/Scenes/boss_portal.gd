extends Area2D

const PROXIMA_CENA = "res://scenes/boss_room.tscn"

func _ready():
	body_entered.connect(_on_body_entered)
	
	var animated_sprite = $AnimatedSprite2D
	if animated_sprite:
		animated_sprite.play("movimento")
	# --------------------------------------

func _on_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		mudar_cena()

func mudar_cena():
	print("Entrando na caverna...")
	get_tree().change_scene_to_file(PROXIMA_CENA)
