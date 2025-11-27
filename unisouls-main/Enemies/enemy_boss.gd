extends CharacterBody2D

const SPEED = 40.0
const ATTACK_RANGE = 70.0
const MAX_HEALTH = 20
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")

# Estado
var health = MAX_HEALTH
var is_dying = false
var player_target = null
var can_attack = true

# Sinais
signal health_changed(new_health, max_health)
signal boss_defeated

# Nós
@onready var anim = $AnimatedSprite2D
@onready var detection_area = $DetectionArea
@onready var hitbox = $Hitbox
@onready var attack_sound = $Attack
@onready var walk_sound = $Walk
@onready var death_sound = $Death
@onready var health_bar = $BossHealthBar

func _ready():
	add_to_group("Boss")
	
	health_bar.init_health(health)

	hitbox.monitoring = false
	hitbox.monitorable = false
	
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)

	$Hurtbox.area_entered.connect(_on_hurtbox_area_entered)

	# CORREÇÃO AQUI ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
	hitbox.body_shape_entered.connect(_on_hitbox_enter)

	emit_signal("health_changed", health, MAX_HEALTH)
	anim.play("Idle")


func _physics_process(delta):
	if is_dying:
		velocity.x = 0
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	var movement = Vector2.ZERO

	if player_target:
		var distance = global_position.distance_to(player_target.global_position)
		var direction = sign(player_target.global_position.x - global_position.x)

		anim.flip_h = direction < 0

		if distance <= ATTACK_RANGE:
			velocity.x = 0
			start_attack()
			walk_sound.stop()
		else:
			movement.x = direction * SPEED
			anim.play("Walk")
			if not walk_sound.playing:
				walk_sound.play()
	else:
		movement.x = move_toward(velocity.x, 0, SPEED)
		anim.play("Idle")
		walk_sound.stop()

	velocity.x = movement.x
	move_and_slide()


# ATAQUE
func start_attack():
	if anim.animation != "Attack":
		anim.play("Attack")
		attack_sound.play()

	hitbox.monitoring = true
	hitbox.monitorable = true

func end_attack():
	hitbox.monitoring = false
	hitbox.monitorable = false


# >>>>>>> FUNÇÃO CORRIGIDA <<<<<<<
func _on_hitbox_enter(body_id, body, body_shape, local_shape):
	if is_dying:
		return

	if anim.animation == "Attack" and body.is_in_group("Player"):
		body.take_damage(1)


# DETECÇÃO
func _on_detection_area_body_entered(body):
	if body.is_in_group("Player"):
		player_target = body

func _on_detection_area_body_exited(body):
	if body == player_target:
		player_target = null


# DANO RECEBIDO
func _on_hurtbox_area_entered(area):
	pass

func take_damage(amount):
	if is_dying:
		return

	health -= amount
	emit_signal("health_changed", health, MAX_HEALTH)

	modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)

	if health <= 0:
		die()
	
	health_bar.health = health
	
# MORTE
func die():
	if is_dying:
		return

	is_dying = true
	anim.play("Death")
	death_sound.play()

	$Hurtbox.set_deferred("monitoring", false)
	detection_area.set_deferred("monitoring", false)
	hitbox.set_deferred("monitoring", false)

	anim.animation_finished.connect(_on_anim_finished)


func _on_anim_finished():
	if anim.animation == "Death":
		emit_signal("boss_defeated")
