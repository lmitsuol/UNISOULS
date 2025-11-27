extends ProgressBar

func _ready():
	var boss = get_tree().get_first_node_in_group("Boss")
	if boss:
		# Conecta o sinal health_changed do Boss à função update_health_bar
		boss.health_changed.connect(update_health_bar)
		if boss.has_method("get_max_health"):
			max_value = boss.get_max_health()
		else:
			max_value = boss.MAX_HEALTH

func update_health_bar(current_health: int, _max_health: int):
	# Atualiza o valor da barra de vida
	value = current_health
	
	# Efeito de flash na barra
	modulate = Color(1, 1, 0.5)
	await get_tree().create_timer(0.05).timeout
	modulate = Color(1, 1, 1)
