extends CharacterBody2D

const SPEED = 80.0
const ATTACK_RANGE = 60.0
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")

var health = 5
var player_target = null

# Estados
var is_dying = false
var is_attacking = false 
var can_attack = true 

@onready var anim = $AnimatedSprite2D
@onready var vision = $Vision
@onready var attack_area = $"Ataque Hitbox"

# Sons
@onready var attack_sound = $Attack
@onready var walk_sound = $Walk
@onready var death_sound = $Death

# Guarda posição original da hitbox
var original_attack_x_abs := 0.0

func _ready():
	add_to_group("Enemy")
	vision.body_entered.connect(_on_vision_body_entered)
	vision.body_exited.connect(_on_vision_body_exited)
	anim.play("Idle")

	# salva posição original absoluta da hitbox
	original_attack_x_abs = abs(attack_area.position.x)


func _physics_process(delta):
	# Gravidade
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Não se move se estiver morrendo
	if is_dying:
		velocity.x = 0
		move_and_slide()
		if walk_sound.playing:
			walk_sound.stop()
		return

	# Não se move durante ataque
	if is_attacking:
		velocity.x = 0
		move_and_slide()
		if walk_sound.playing:
			walk_sound.stop()
		return

	var movement = Vector2.ZERO

	if player_target:
		var direction = sign(player_target.global_position.x - global_position.x)
		var horizontal_dist = abs(player_target.global_position.x - global_position.x)

		# Flip do lobo + ajuste correto da hitbox
		if direction != 0:
			anim.flip_h = direction < 0
			if anim.flip_h:
				attack_area.position.x = -original_attack_x_abs
			else:
				attack_area.position.x = original_attack_x_abs

		# ATAQUE baseado APENAS na distância horizontal
		if horizontal_dist <= ATTACK_RANGE and can_attack:
			start_attack()
		else:
			movement.x = direction * SPEED
			anim.play("Walk")

			if not walk_sound.playing:
				walk_sound.play()

	else:
		movement.x = move_toward(velocity.x, 0, SPEED)
		anim.play("Idle")

		if walk_sound.playing:
			walk_sound.stop()

	velocity.x = movement.x
	move_and_slide()


func start_attack():
	is_attacking = true
	can_attack = false

	anim.play("Attack")
	attack_sound.play()  # SOM DO ATAQUE

	await get_tree().create_timer(0.4).timeout

	if not is_dying:
		check_hit_collision()

	await anim.animation_finished

	is_attacking = false

	await get_tree().create_timer(1.0).timeout
	can_attack = true


func check_hit_collision():
	var bodies = attack_area.get_overlapping_bodies()

	for body in bodies:
		if body.is_in_group("Player"):
			if body.has_method("take_damage"):
				body.take_damage(1)
			break


func _on_vision_body_entered(body):
	if body.is_in_group("Player"):
		player_target = body


func _on_vision_body_exited(body):
	if body == player_target:
		player_target = null


func take_damage(damage_amount: int):
	if is_dying: return

	health -= damage_amount
	modulate = Color(1, 0.3, 0.3)

	var knockback_dir = 1 if anim.flip_h else -1
	velocity.x = knockback_dir * 100

	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)

	if health <= 0:
		die()


func die():
	if is_dying: return

	is_dying = true
	anim.play("Death")
	death_sound.play()

	if walk_sound.playing:
		walk_sound.stop()
	if attack_sound.playing:
		attack_sound.stop()

	vision.set_deferred("monitoring", false)
	attack_area.set_deferred("monitoring", false)

	anim.animation_finished.connect(_on_animated_sprite_2d_animation_finished)


func _on_animated_sprite_2d_animation_finished():
	if is_dying and anim.animation == "Death":
		queue_free()
