extends CharacterBody2D

signal health_changed(new_health)

var is_attacking = false
var is_jumping = false
var is_dying = false
var is_hit = false

const SPEED = 150.0
const JUMP_VELOCITY = -370.0
const KNOCKBACK_FORCE = 200.0
const KNOCKBACK_FRICTION = 10.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- CHECKPOINT ---
var last_checkpoint_pos: Vector2 = Vector2.ZERO
var start_position: Vector2

@onready var anim = $AnimatedSprite2D
@onready var death_timer = $Death_Timer
@onready var invincibility_timer = $InvincibilityTimer

func _ready() -> void:
	start_position = global_position
	add_to_group("Player")
	death_timer.connect("timeout", Callable(self, "_on_DeathTimer_timeout"))
	invincibility_timer.timeout.connect(_on_InvincibilityTimer_timeout)
	$AttackHitbox.monitoring = false


# ---------------- CHECKPOINT ----------------

func save_checkpoint(pos: Vector2):
	last_checkpoint_pos = pos
	print("Checkpoint salvo:", pos)

func respawn():
	print("Respawn no checkpoint:", last_checkpoint_pos)
	global_position = last_checkpoint_pos
	velocity = Vector2.ZERO
	is_dying = false
	is_hit = false
	# Garante que o ataque reseta ao morrer/renascer
	is_attacking = false
	$AttackHitbox.monitoring = false
	modulate = Color(1,1,1,1)
	anim.play("Idle")
	Global.player_lives = Global.max_lives


# ---------------- MOVIMENTO ----------------

func _physics_process(delta: float) -> void:
	# Correção: Garante que a hitbox desligue se o estado de ataque for cancelado
	if not is_attacking and $AttackHitbox.monitoring:
		$AttackHitbox.set_deferred("monitoring", false)

	if is_dying or is_attacking:
		velocity.x = 0
		if not is_on_floor():
			velocity.y += gravity * delta
		move_and_slide()
		return

	if is_hit:
		if not is_on_floor():
			velocity.y += gravity * delta

		velocity.x = move_toward(velocity.x, 0, KNOCKBACK_FRICTION)
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		is_jumping = false

	# Ataque
	if Input.is_action_just_pressed("Atacar") and not is_attacking:
		is_attacking = true
		anim.play("Attack 1")
		velocity.x = 0
		$AttackHitbox.set_deferred("monitoring", true)
		return

	# Pulo
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true

	# Movimento
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		anim.flip_h = direction < 0
		
		# Correção: Vira a hitbox junto com o sprite
		if direction < 0:
			$AttackHitbox.scale.x = -1
		else:
			$AttackHitbox.scale.x = 1
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	update_animation(direction)
	move_and_slide()


# ------------- ATAQUE ---------------

func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	var target = area

	if area.has_method("take_damage") and area.is_in_group("Enemy"):
		pass
	elif area.get_parent() and (area.get_parent().is_in_group("Boss") or area.get_parent().is_in_group("Enemy")):
		target = area.get_parent()
	else:
		return

	if target.has_method("take_damage"):
		target.take_damage(1)

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "Attack 1":
		is_attacking = false
		$AttackHitbox.set_deferred("monitoring", false)


# ------------- DANO / HIT ----------------

func take_damage(damage_amount: int = 1):
	if is_hit or is_dying:
		return
	
	# Correção: Cancela o ataque e desliga a hitbox ao tomar dano
	if is_attacking:
		is_attacking = false
		$AttackHitbox.set_deferred("monitoring", false)
		
	is_hit = true
	Global.player_lives -= damage_amount

	emit_signal("health_changed", Global.player_lives)

	if Global.player_lives <= 0:
		die()
		return

	modulate = Color(1, 0.3, 0.3, 0.5)
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
	modulate = Color(1, 1, 1, 1)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		var knockback_direction = -sign(body.global_position.x - global_position.x)
		if knockback_direction == 0:
			knockback_direction = 1

		take_damage(1)

		velocity.x = knockback_direction * KNOCKBACK_FORCE
		velocity.y = JUMP_VELOCITY / 1.5


# ------------------- MORTE -------------------

func die():
	if last_checkpoint_pos != Vector2.ZERO:
		print("Voltando ao checkpoint!")
		await get_tree().create_timer(1.0).timeout
		respawn()
		return

	# Game Over NORMAL
	is_dying = true
	anim.play("Die")
	print("Game Over")

	if Music.has_method("play_music"):
		Music.play_music("gameover")

	get_tree().change_scene_to_file("res://Menu/gameover.tscn")


# -------------------- ANIMAÇÕES ---------------------

func update_animation(direction):
	if is_dying:
		return

	if is_attacking:
		return

	if is_jumping:
		anim.play("Jump")
	elif direction != 0:
		anim.flip_h = (direction < 0)
		anim.play("Walk")
	else:
		anim.play("Idle")


# Timer removido porque recarregar a cena destrói o checkpoint
func _on_DeathTimer_timeout():
	pass
