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
# IMPORTANTE: Certifique-se que o nome do nó no editor é exatamente "Ataque Hitbox"
@onready var attack_area = $"Ataque Hitbox" 

func _ready():
	add_to_group("Enemy")
	vision.body_entered.connect(_on_vision_body_entered)
	vision.body_exited.connect(_on_vision_body_exited)
	anim.play("Idle")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	if is_dying:
		velocity.x = 0
		move_and_slide()
		return

	if is_attacking:
		velocity.x = 0
		move_and_slide()
		return 
		
	var movement = Vector2.ZERO
	
	if player_target:
		var direction = sign(player_target.global_position.x - global_position.x)
		var distance = global_position.distance_to(player_target.global_position)
		
		if direction != 0:
			anim.flip_h = direction < 0
			# Inverte a posição da área de ataque para acompanhar a boca do lobo
			if direction < 0:
				attack_area.position.x = -abs(attack_area.position.x)
			else:
				attack_area.position.x = abs(attack_area.position.x)
		
		if distance <= ATTACK_RANGE and can_attack:
			start_attack()
		else:
			movement.x = direction * SPEED
			anim.play("Walk")
			
	else:
		movement.x = move_toward(velocity.x, 0, SPEED)
		anim.play("Idle")

	velocity.x = movement.x
	move_and_slide()

func start_attack():
	is_attacking = true
	can_attack = false
	anim.play("Attack")
	
	# 0.4 segundos é uma sugestão. Ajuste esse tempo para casar com a animação da mordida
	await get_tree().create_timer(0.4).timeout 
	
	if not is_dying:
		check_hit_collision()
	
	await anim.animation_finished
	is_attacking = false
	
	# Tempo de descanso entre ataques
	await get_tree().create_timer(1.0).timeout
	can_attack = true

func check_hit_collision():
	# Verifica quem está dentro da área de ataque no momento exato
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
	
	# CORRIGIDO: Calcula a direção do recuo baseado na direção que o sprite está olhando
	# Se flip_h é true (esquerda), empurra para direita (1), senão esquerda (-1)
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
	
	vision.set_deferred("monitoring", false)
	attack_area.set_deferred("monitoring", false)
	
	anim.animation_finished.connect(_on_animated_sprite_2d_animation_finished)

func _on_animated_sprite_2d_animation_finished():
	if is_dying and anim.animation == "Death":
		queue_free()
