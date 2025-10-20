extends CharacterBody2D

var is_attacking = false
var is_jumping = false
var is_dying = false

const SPEED = 150.0
const JUMP_VELOCITY = -350.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = $AnimatedSprite2D
@onready var death_timer = $Death_Timer

func _ready() -> void:
	add_to_group("Player")
	death_timer.connect("timeout", Callable(self, "_on_DeathTimer_timeout"))

func _physics_process(delta: float) -> void:
	if is_dying:
		return
	
	# Gravidade
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		is_jumping = false

	# --- ATAQUE ---
	if Input.is_action_just_pressed("Atacar") and not is_attacking:
		is_attacking = true
		anim.play("Attack 1")
		velocity.x = 0  # trava o movimento durante ataque
		return

	# Se terminou a animação de ataque, libera movimento de novo
	if is_attacking and not anim.is_playing():
		is_attacking = false

	# --- PULO ---
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		
	# --- PULO LONGO ---
	#if Input.is_action_just_pressed("??") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY

	# --- MOVIMENTO ---
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		anim.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	update_animation(direction)
	move_and_slide()

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

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.	is_in_group("Enemy") and body.is_alive:
		die()
		
func die():
	if is_dying:
		return
	
	is_dying = true
	anim.play("Die")
	Global.player_lives -= 1
	
	if Global.player_lives > 0:
		print("Reloading Scene")
		get_tree().reload_current_scene()
	else:
		get_tree().change_scene_to_file("res://Menu/gameover.tscn")

func on_DeathTimer_timeout():
	get_tree().reload_current_scene()
