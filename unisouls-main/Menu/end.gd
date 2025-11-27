extends Node2D

const CREDITS_SCENE_PATH = "res://Menu/credits.tscn"
const MAIN_MENU_SCENE_PATH = "res://Menu/main_menu.tscn"

func _ready() -> void:
	Music.play_music("end")
	
func _process(delta):
	# Permite que o jogador pule (skip) a cena de fim de jogo
	if Input.is_action_just_pressed("ui_cancel"):
		skip_to_credits()

# Esta função é chamada quando a cutscene de fim de jogo termina
# (ex: um sinal de AnimationPlayer ou a tela fica por tempo suficiente).
func _on_finished():
	skip_to_credits()

# Função para transicionar para a cena de Créditos.
func skip_to_credits():
	get_tree().change_scene_to_file(CREDITS_SCENE_PATH)
