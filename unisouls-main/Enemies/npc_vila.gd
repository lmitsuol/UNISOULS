extends Node2D # Ou Node2D, dependendo do seu nó

# Variável para o nome do Timeline do Dialogic que você quer iniciar
@export var dialogic_timeline_name: String = "Intro" 

# Referências aos Nodes filhos
@onready var interaction_area: Area2D = $InteractionArea
@onready var interaction_prompt: Label = $InteractionPrompt # O Label com "Pressione E"

var player_in_range: bool = false
var dialogue_is_running: bool = false # Novo controle

# Chamado quando o nó entra na árvore de cena
func _ready() -> void:
	interaction_prompt.visible = false
	
	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)
	
	# MUDE A CONEXÃO AQUI: Use o sinal global 'timeline_ended' do Dialogic
	Dialogic.timeline_ended.connect(_on_dialogue_finished)
	# Você não precisa mais do sinal 'signal_event' para o controle básico
	# Dialogic.signal_event.connect(_on_dialogic_signal) 


# Chamado a cada frame
func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact") and not dialogue_is_running:
		start_dialogue()


func _on_interaction_area_body_entered(body: Node2D):
	# (Mantido como estava)
	if body.is_in_group("Player") or body.name == "Player": 
		player_in_range = true
		interaction_prompt.visible = true

func _on_interaction_area_body_exited(body: Node2D):
	# (Mantido como estava)
	if body.is_in_group("Player") or body.name == "Player":
		player_in_range = false
		interaction_prompt.visible = false

func start_dialogue():
	if dialogue_is_running:
		return 
		
	if dialogic_timeline_name:
		# Apenas inicie o diálogo, sem tentar conectar o sinal aqui
		Dialogic.start(dialogic_timeline_name)
		
		# O diálogo está ativo, marque como verdadeiro
		dialogue_is_running = true 

# Esta função será chamada pelo sinal global Dialogic.timeline_ended
func _on_dialogue_finished(timeline_name: String):
	# Verifica se o diálogo que terminou é o que iniciamos (opcional)
	# if timeline_name == dialogic_timeline_name:
	
	# Apenas redefina o controle
	dialogue_is_running = false 
	print("Diálogo com NPC finalizado: " + timeline_name)
