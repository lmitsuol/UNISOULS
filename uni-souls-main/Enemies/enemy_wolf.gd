extends CharacterBody2D

const SPEED = 80.0
const ATTACK_RANGE = 40.0 # Distância para iniciar o ataque
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var health = 5
var is_dying = false
var last_direction = 1

@onready var anim = $AnimatedSprite2D
@onready var hitbox = $Hitbox 
@onready var vision = $Vision
var player_target = null # Variável para armazenar a referência ao Player

func _ready():
	add_to_group("Enemy")
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	vision.body_entered.connect(_on_vision_body_entered)
	vision.body_exited.connect(_on_vision_body_exited)
	anim.play("Idle")

func _physics_process(delta):
	# Aplica gravidade
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	if is_dying:
		velocity.x = 0
		move_and_slide()
		return
		
	var movement = Vector2.ZERO
	
	if player_target:
		# Player detectado: calcula a direção e a distância
		var direction = sign(player_target.global_position.x - global_position.x)
		var distance = global_position.distance_to(player_target.global_position)
		
		# DEFINE A VISÃO DO LOBO
		# Usaremos o flip_h, que é mais eficiente que scale.x
		anim.flip_h = direction < 0
		
		if distance <= ATTACK_RANGE:
			# Estado de Ataque
			velocity.x = 0
			anim.play("Attack")
		else:
			# Persegue o Player
			movement.x = direction * SPEED
			anim.play("Walk")
			
	else:
		# Sem Player: Para e fica ocioso
		movement.x = move_toward(velocity.x, 0, SPEED)
		anim.play("Idle")

	velocity.x = movement.x
	move_and_slide()

# Detecta o Player entrando na área de Visão
func _on_vision_body_entered(body):
	if body.is_in_group("Player"):
		player_target = body

# Player saindo da área de Visão
func _on_vision_body_exited(body):
	if body == player_target:
		player_target = null

# Causa dano quando a Hitbox de ataque do Lobo toca o Player
func _on_hitbox_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		body.take_damage(1)

func take_damage(damage_amount: int):
	if is_dying:
		return
		
	health -= damage_amount
	
	# Efeito visual de dano (vermelho rápido)
	modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout 
	modulate = Color(1, 1, 1) # Volta à cor normal

	if health <= 0:
		die()

func die():
	if is_dying:
		return
		
	is_dying = true
	anim.play("Death") 
	
	# Desativa a Hitbox e Visão para não causar mais dano nem perseguir
	hitbox.set_deferred("monitoring", false)
	vision.set_deferred("monitoring", false)
	
	# Conecta para remover o nó após a animação
	anim.animation_finished.connect(_on_animated_sprite_2d_animation_finished)

# Remove o Lobo após a animação de morte terminar
func _on_animated_sprite_2d_animation_finished():
	if is_dying and anim.animation == "Death":
		queue_free()
