extends Node2D

# Variável para referenciar o nó PointLight2D do jogador (opcional, mas bom para referência)
var player_light: PointLight2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Configurações de Área e Música
	Music.play_music("boss") # Toca a música do boss
	Global.set_current_area("A Sala do Golem")
	
	# --- Lógica para Ligar a Luz do Jogador ---
	
	# 1. Tenta encontrar o nó principal do jogador na cena atual
	var player_node = get_node_or_null("Player") 
	
	if player_node:
		# 2. Tenta encontrar o nó PointLight2D dentro do jogador
		player_light = player_node.get_node_or_null("PointLight2D")
		
		# 3. Habilita a luz se ela for encontrada (pois estamos na área escura)
		if player_light:
			player_light.set_enabled(true)
			# Ou use player_light.show() se você o escondeu em vez de desabilitar.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
