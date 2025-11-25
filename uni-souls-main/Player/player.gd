extends CharacterBody2D

signal health_changed(new_health)

var is_attacking = false
var is_jumping = false
var is_dying = false
var is_hit = false

const SPEED = 150.0
const JUMP_VELOCITY = -370.0
const KNOCKBACK_FORCE = 200.0 # Força horizontal do empurrão
const KNOCKBACK_FRICTION = 10.0 # O quão rápido ele para depois de ser empurrado

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = $AnimatedSprite2D
@onready var death_timer = $Death_Timer
@onready var invincibility_timer = $InvincibilityTimer

func _ready() -> void:
	add_to_group("Player")
	death_timer.connect("timeout", Callable(self, "_on_DeathTimer_timeout"))
	invincibility_timer.timeout.connect(_on_InvincibilityTimer_timeout)
	$AttackHitbox.monitoring = false   # IMPORTANTE: desliga a hitbox no início

func _physics_process(delta: float) -> void:
	# 1. PRIORIDADE MÁXIMA: Morte ou Ataque (Travam totalmente o movimento)
	if is_dying or is_attacking:
		velocity.x = 0
		if not is_on_floor():
			velocity.y += gravity * delta
		move_and_slide()
		return

	# 2. ESTADO DE DANO (KNOCK-BACK):
	# Se tomou hit, não aceita input, mas permite que a velocidade do empurrão aconteça
	if is_hit:
		if not is_on_floor():
			velocity.y += gravity * delta
		
		# Cria um atrito para o personagem não deslizar para sempre
		velocity.x = move_toward(velocity.x, 0, KNOCKBACK_FRICTION)
		
		move_and_slide()
		return # Retorna para impedir que o código de movimento abaixo rode

	# 3. COMPORTAMENTO NORMAL (Gravidade)
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		is_jumping = false

	# --- ATAQUE ---
	if Input.is_action_just_pressed("Atacar") and not is_attacking:
		is_attacking = true
		anim.play("Attack 1")
		velocity.x = 0
		$AttackHitbox.monitoring = true     # LIGA A HITBOX
		return

	# --- PULO ---
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		
	# --- MOVIMENTO ---
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		anim.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	update_animation(direction)
	move_and_slide()

# HITBOX DE ATAQUE DO PLAYER
func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	var target = area
	
	if area.has_method("take_damage") and area.is_in_group("Enemy"):
		pass
	elif area.get_parent() and (area.get_parent().is_in_group("Boss") or area.get_parent().is_in_group("Enemy")):
		target = area.get_parent()
	else:
		return

	if target.has_method("take_damage"):
		target.take_damage(1)  # SÓ DÁ DANO — não desliga hitbox aqui

# TERMINOU A ANIMAÇÃO → DESLIGA HITBOX E ATAQUE
func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "Attack 1":
		is_attacking = false
		$AttackHitbox.monitoring = false   # DESLIGA AQUI!

# FUNÇÃO PARA RECEBER DANO
func take_damage(damage_amount: int = 1):
	if is_hit or is_dying:
		return
		
	is_hit = true
	Global.player_lives -= damage_amount
	
	emit_signal("health_changed", Global.player_lives)
	
	if Global.player_lives <= 0:
		die()
		return

	# Efeito visual de dano
	modulate = Color(1, 0.3, 0.3, 0.5)
	invincibility_timer.start(1.5)
	set_process(true) # Ativa o _process para piscar

# PISCAR ENQUANTO ESTIVER INVULNERÁVEL
func _process(_delta):
	if is_hit:
		var total_time = Time.get_ticks_msec() / 1000.0
		anim.modulate.a = lerp(0.5, 1.0, fmod(total_time, 0.2) / 0.2)
	else:
		anim.modulate.a = 1.0
		set_process(false)

# FIM DA INVULNERABILIDADE
func _on_InvincibilityTimer_timeout():
	is_hit = false
	anim.modulate.a = 1.0
	modulate = Color(1, 1, 1, 1)

# --- COLISÃO COM INIMIGO (APLICA O KNOCK-BACK AQUI) ---
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		# Primeiro calcula a direção: Se inimigo está na direita, joga pra esquerda
		var knockback_direction = -sign(body.global_position.x - global_position.x)
		
		# Se a direção for 0 (estão na mesma posição x), joga para um lado padrão (ex: direita)
		if knockback_direction == 0:
			knockback_direction = 1
			
		# Aplica o dano (que seta is_hit = true)
		take_damage(1)
		
		# Aplica a velocidade do Knockback
		velocity.x = knockback_direction * KNOCKBACK_FORCE
		velocity.y = JUMP_VELOCITY / 1.5 # Um pulinho para cima

func die():
	if is_dying:
		return
	
	is_dying = true
	anim.play("Die")
	print("Game Over")
	if Music.has_method("play_music"):
		Music.play_music("gameover")
	get_tree().change_scene_to_file("res://Menu/gameover.tscn")

func update_animation(direction):
	if is_dying:
		return
		
	if is_jumping:
		anim.play("Jump")
	elif direction != 0:
		anim.flip_h = (direction < 0)
		anim.play("Walk")
	else:
		anim.play("Idle")

	# Overrides de animação
	if not is_attacking:
		if not is_on_floor():
			anim.play("Jump")
		elif velocity.x == 0:
			anim.play("Idle")
		else:
			anim.play("Walk")

func _on_DeathTimer_timeout():
	get_tree().reload_current_scene()
