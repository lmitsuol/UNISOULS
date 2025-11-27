extends Node2D 

const MAIN_MENU_SCENE_PATH = "res://Menu/main_menu.tscn"

func _ready():
	Music.play_music("end")
	var player = $AnimationPlayer

	#Conecta o sinal 'animation_finished' do AnimationPlayer
	# para que, quando a animação terminar, chamemos a função de transição.
	player.animation_finished.connect(go_to_main_menu)
	
	#Inicia a animação de rolagem (ScrollCredits)
	player.play("scroll_credits")

func _process(delta):
	# Permite que o jogador pule (skip) os créditos.
	if Input.is_action_just_pressed("ui_cancel"):
		go_to_main_menu()

# Função que será chamada quando a animação acabar OU a tecla for pressionada.
func go_to_main_menu(_anim_name = ""): # O sinal animation_finished passa um nome de animação, por isso o argumento.
	Music.stop()
	# Evita erros se a função for chamada mais de uma vez.
	if get_tree().current_scene.name != "MainMenu": # Ajuste o nome do nó raiz da sua cena de menu
		get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
