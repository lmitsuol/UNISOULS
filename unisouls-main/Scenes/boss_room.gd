extends Node2D

var player_light: PointLight2D = null

func _ready() -> void:
	Music.play_music("boss") 
	Global.set_current_area("A Sala do Golem")

	var player_node = get_node_or_null("Player") 

	if player_node:
		player_light = player_node.get_node_or_null("PointLight2D")
		if player_light:
			player_light.set_enabled(true)

func _process(delta: float) -> void:
	pass

func _on_boss_defeated():
	# 1. Congela o jogo e o input
	get_tree().paused = true 
	
	# 2. Aguarda um tempo (ex: 3 segundos) para a animação de morte e som do boss terminarem
	# Remova esta linha se não quiser esperar.
	await get_tree().create_timer(3.0).timeout
	
	# 3. Define o caminho da cena de créditos
	# **VERIFIQUE E AJUSTE ESTE CAMINHO PARA ONDE ESTÁ SEU ARQUIVO DE CRÉDITOS!**
	var end_path = "res://Menu/end.tscn" 
	
	# 4. Mudar a cena
	var error = get_tree().change_scene_to_file(end_path)
	
	if error != OK:
		print("Erro ao mudar de cena para os Créditos: ", error)
	
	# 5. Opcional: Descongela o jogo se a cena de créditos não for fazer isso sozinha
	get_tree().paused = false
