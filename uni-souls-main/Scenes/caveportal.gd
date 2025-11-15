extends Area2D

const PROXIMA_CENA = "res://scenes/cave.tscn"

func _ready():
	# Conecta o sinal body_entered para saber quando um corpo (o Player) entra
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	# 1. Verifica se o corpo que entrou é o Player.
	#    (Assumindo que o Player está no grupo "Player")
	if body.is_in_group("Player"):
		mudar_cena()

func mudar_cena():
	# A função que realmente carrega a nova cena
	print("Entrando na caverna...")
	get_tree().change_scene_to_file(PROXIMA_CENA)
