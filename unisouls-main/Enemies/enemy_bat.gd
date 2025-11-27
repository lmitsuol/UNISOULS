extends CharacterBody2D

const SPEED = 50.0
const GRAVITY = 0
var direction = -1 
var health = 3
var is_dying = false

@onready var anim = $AnimatedSprite2D
@onready var point_a = $Patrulha/PatrolPointA.global_position
@onready var point_b = $Patrulha/PatrolPointB.global_position
@onready var hitbox = $Hitbox # Area2D
@onready var fly_sound = $Fly
@onready var death_sound = $Death

func _ready():
	add_to_group("Enemy")
	# Conecta o sinal 'body_entered' da Hitbox para causar dano ao Player
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	# Garante que ele comece a patrulhar na direção correta
	direction = sign(point_b.x - global_position.x)
	anim.play("Walk")
	anim.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
	fly_sound.play()

func _physics_process(delta):
	
	velocity.y += GRAVITY * delta
	
	# Movimento de patrulha horizontal
	velocity.x = SPEED * direction
	
	# Verifica se atingiu um dos pontos de patrulha para inverter a direção
	var target_x = point_b.x if direction == 1 else point_a.x
	
	if abs(global_position.x - target_x) < 5: # Se estiver perto do ponto
		direction *= -1 # Inverte a direção
		
	# Inverte a animação (sprite)
	anim.flip_h = direction == -1
	
	move_and_slide()

# --- FUNÇÕES DE VIDA/MORTE DO INIMIGO ---

# Esta função é chamada pelo script do Player ao atacar o inimigo
func take_damage(damage_amount: int):
	if is_dying:
		return
		
	health -= damage_amount
	
	# Efeito visual de dano (piscar/cor)
	modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout # Espera 0.1s para o efeito
	modulate = Color(1, 1, 1)

	if health <= 0:
		die()

func die():
	if is_dying:
		return
		
	is_dying = true
	anim.play("Death")
	death_sound.play()
	# Desativa a Hitbox para que o Player não tome mais dano dele
	hitbox.set_deferred("monitoring", false) 
	
	fly_sound.stop()
	
# Função que remove o inimigo após a animação de Morte
func _on_animated_sprite_2d_animation_finished():
	if is_dying and anim.animation == "Death":
		queue_free() # Remove o nó da cena

# --- DANO AO PLAYER POR TOQUE ---
func _on_hurtbox_area_entered(area: Area2D):
	# O Morcego SÓ toma dano se for do grupo de ataque do Player.
	if area.is_in_group("PlayerHitbox"): 
		take_damage(1)
		# Desliga o Hitbox do Player para evitar múltiplos hits
		area.monitoring = false

# --- DANO AO PLAYER POR TOQUE (Bat atingindo o Player) ---
func _on_hitbox_body_entered(body: Node2D):
	if is_dying:
		return
	
	if body.is_in_group("Player"):
		body.take_damage(1)
		
