extends CanvasLayer

@onready var player = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	if player:
		player.health_changed.connect(update_hearts)
		update_hearts(Global.player_lives)

func update_hearts(new_health: int):
	const heart_width = 1024
	$HeartsFull.size.x = new_health * heart_width
	$HeartsEmpty.size.x = (Global.max_lives - new_health) * heart_width
	$HeartsEmpty.position.x = $HeartsFull.position.x + $HeartsFull.size.x * $HeartsFull.scale.x
