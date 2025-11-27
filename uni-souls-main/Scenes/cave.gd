extends Node2D

var player_light: PointLight2D = null

func _ready() -> void:
	Music.play_music("caverna")
	Global.set_current_area("A Caverna")
	
	var player_node = get_node_or_null("Player") 
	if player_node:
		player_light = player_node.get_node_or_null("PointLight2D")
		
	if player_light:
		player_light.set_enabled(true)

func _process(delta: float) -> void:
	pass

func _on_interact_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.die()

func _on_interact_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.die()
