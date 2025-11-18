extends CharacterBody2D

signal health_changed(new_health)

var is_attacking = false
var is_jumping = false
var is_dying = false
var is_hit = false

const SPEED = 150.0
const JUMP_VELOCITY = -370.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = $AnimatedSprite2D
@onready var death_timer = $Death_Timer
@onready var invincibility_timer = $InvincibilityTimer

func _ready() -> void:
	add_to_group("Player")
	death_timer.connect("timeout", Callable(self, "_on_DeathTimer_timeout"))
	invincibility_timer.timeout.connect(_on_InvincibilityTimer_timeout)

func _physics_process(delta: float) -> void:
	# Trava o movimento se estiver morrendo OU se estiver no estado 'is_hit' (levando dano)
	if is_dying or is_hit or is_attacking:
		velocity.x = 0
		if not is_on_floor():
			velocity.y += gravity * delta
		move_and_slide()
		return
	
	# Gravidade
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		is_jumping = false

	# --- ATAQUE ---
	if Input.is_action_just_pressed("Atacar"):
		is_attacking = true
		anim.play("Attack 1")
		velocity.x = 0
		$AttackHitbox.monitoring = true
		return

	
	# --- PULO (Bloco movido de volta para _physics_process) ---
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		
	# --- MOVIMENTO (Bloco movido de volta para _physics_process) ---
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		anim.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	update_animation(direction)
	move_and_slide()

func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	var target = area
	if area.has_method("take_damage") and area.is_in_group("Enemy"):
		pass
	elif area.get_parent() and (area.get_parent().is_in_group("Boss") or area.get_parent().is_in_group("Enemy")):
		target = area.get_parent()
	else:
		return
		
	# 3. Aplica o dano e desativa o monitoring
	if target.has_method("take_damage"):
		target.take_damage(1)
		$AttackHitbox.monitoring = false
		return
			
func _on_animated_sprite_2d_animation_finished() -> void:
	# Lógica principal: Desativa o ataque
	if anim.animation == "Attack 1":
		is_attacking = false
		$AttackHitbox.monitoring = false

func take_damage(damage_amount: int = 1):
	if is_hit or is_dying:
		return
		
	is_hit = true
	Global.player_lives -= damage_amount
	
	emit_signal("health_changed", Global.player_lives)
	
	if Global.player_lives <= 0:
		die()
		return
	modulate = Color(1,0.3,0.3,0.5)
	invincibility_timer.start(1.5)
	set_process(true)

func _process(_delta):
	if is_hit:
		var total_time = Time.get_ticks_msec() / 1000.0
		anim.modulate.a = lerp(0.5, 1.0, fmod(total_time, 0.2) / 0.2)
	else:
		anim.modulate.a = 1.0
		set_process(false)

func _on_InvincibilityTimer_timeout():
	is_hit = false
	anim.modulate.a = 1.0
	modulate = Color(1,1,1,1)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		take_damage(1)
		var knockback_direction = -sign(position.x - body.position.x)
		velocity.x = knockback_direction * 200
		velocity.y = JUMP_VELOCITY / 2

func die():
	if is_dying:
		return
	
	is_dying = true
	anim.play("Die")
	print("Game Over")
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

	# --- ANIMAÇÕES ---
	if not is_attacking:
		if not is_on_floor():
			anim.play("Jump")
		elif velocity.x == 0:
			anim.play("Idle")
		else:
			anim.play("Walk")

func on_DeathTimer_timeout():
	get_tree().reload_current_scene()
