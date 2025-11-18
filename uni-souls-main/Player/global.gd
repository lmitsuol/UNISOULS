extends Node

var max_lives = 5
var player_lives = max_lives

func _ready():
	var boss = get_tree().get_first_node_in_group("Boss") 
	if boss:
		boss.boss_defeated.connect(on_boss_defeated)

func on_boss_defeated():
	print("BOSS DERROTADO! INICIANDO FIM DE JOGO.")
	
	# 1. Congela o jogo para o momento dramático
	get_tree().paused = true
	
	# 2. Efeito visual dramático
	await get_tree().create_timer(5.0).timeout
	
	# 3. Descongela e carrega a cena de Créditos
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Menu/end.tscn")
	
# Função chamada por qualquer cena para definir o nome da área.
func set_current_area(name: String):
	# Procura o CanvasLayer (HUD)
	var area_label = get_tree().get_first_node_in_group("AreaHUD")
	
	if area_label and area_label.has_method("set_area_name"):
		# Chama a função de atualização da Label
		area_label.set_area_name(name)
