extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -350.0

@onready var anim = $AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_attacking = false

func _physics_process(delta: float) -> void:
	# Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

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
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# --- PULO LONGO ---
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# --- MOVIMENTO ---
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		anim.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# --- ANIMAÇÕES ---
	if not is_attacking:
		if not is_on_floor():
			anim.play("Jump")
		elif velocity.x == 0:
			anim.play("Idle")
		else:
			anim.play("Walk")

	move_and_slide()
