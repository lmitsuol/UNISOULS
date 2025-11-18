extends CharacterBody2D

const SPEED = 40.0         # o Golem é lento
const ATTACK_RANGE = 70.0  # Distância de ataque
const MAX_HEALTH = 10      # Muita vida!
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")

# Variáveis de Estado
var health = MAX_HEALTH
var is_dying = false
var player_target = null

# Sinais para o HUD e Fim de Jogo
signal health_changed(new_health, max_health)
signal boss_defeated

# Referências de Nós
@onready var anim = $AnimatedSprite2D
@onready var detection_area = $DetectionArea

func _ready():
	add_to_group("Boss")
	
	# CONECTA OS SINAIS DE DETECÇÃO (Vision)
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	
	# Conecta o Hurtbox ao take_damage (o Player vai se comunicar com o Hurtbox)
	$Hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	
	# Emite o sinal inicial para o HUD carregar a vida
	emit_signal("health_changed", health, MAX_HEALTH)
	anim.play("Idle")

func _physics_process(delta):
	if is_dying:
		velocity.x = 0
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		move_and_slide()
		return

	# Aplica gravidade
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	var movement = Vector2.ZERO

	if player_target:
		var distance = global_position.distance_to(player_target.global_position)
		var direction = sign(player_target.global_position.x - global_position.x)
		
		# FLIP: Vira o Golem para onde o Player está
		anim.flip_h = direction < 0
		
		if distance <= ATTACK_RANGE:
			# Estado de Ataque
			velocity.x = 0
			anim.play("Attack")
		else:
			# Persegue o Player (Walk)
			movement.x = direction * SPEED
			anim.play("Walk")
			
	else:
		# Sem Player na DetectionArea: Idle
		movement.x = move_toward(velocity.x, 0, SPEED)
		anim.play("Idle")

	velocity.x = movement.x
	move_and_slide()

# --- DETECÇÃO ---
func _on_detection_area_body_entered(body):
	if body.is_in_group("Player"):
		player_target = body

func _on_detection_area_body_exited(body):
	if body == player_target:
		player_target = null

# --- DANO ---
func _on_boss_hitbox_body_entered(body: Node2D):
	if is_dying:
		return

	# SÓ CAUSA DANO DURANTE A ANIMAÇÃO DE ATAQUE
	if anim.animation == "Attack" and body.is_in_group("Player"):
		body.take_damage(1)

# É chamado quando a Hitbox de ataque do Player atinge o Hurtbox do Boss
func _on_hurtbox_area_entered(area: Area2D):
	# Assumindo que a hitbox do Player está no grupo "PlayerHitbox"
	if area.is_in_group("PlayerHitbox"):
		take_damage(1) # O dano de um ataque do Player

func take_damage(damage_amount: int):
	if is_dying:
		return
		
	health -= damage_amount
	emit_signal("health_changed", health, MAX_HEALTH) # Notifica o HUD

	# Efeito visual de dano
	modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)

	if health <= 0:
		die()

func die():
	if is_dying:
		return
		
	is_dying = true
	anim.play("Death")
	
	# Desativa caixas de colisão para não ter mais interação
	set_collision_mask_value(1, false) # Desliga a colisão com o chão
	$Hurtbox.set_deferred("monitoring", false)
	detection_area.set_deferred("monitoring", false)
	
	# Conecta para iniciar a Morte Épica após a animação
	anim.animation_finished.connect(_on_animated_sprite_2d_animation_finished)

# Inicia a sequência de fim de jogo
func _on_animated_sprite_2d_animation_finished():
	if is_dying and anim.animation == "Death":
		# 1. Emite o sinal global de vitória
		emit_signal("boss_defeated")
		
		# 2. Deixa o Golem parado na cena para o momento dramático
		queue_free() # ou queue_free() após o efeito visual
