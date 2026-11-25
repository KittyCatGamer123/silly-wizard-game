@abstract
extends CharacterBody2D
class_name Enemy

var target: Player = null

@export var health: float = 15
@export var contact_damage: int = 14
@export var knockback_force: int = 300
@export var knockback_resist: int = 5
@export var knockback_friction: float = 180.0
var knockback_velocity: float = 0.0
var is_dead = false

@onready var anin_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea

@export var accel_speed = 500
@export var max_speed = 80

var debuffs_stack = []
var weakened_debuff_effect: GPUParticles2D = null
var onfire_debuff_effect: GPUParticles2D = null

const onfire_damage_rate = 1 # per second

func _ready() -> void:
	init_debuff_scenes()
	init_enemy_data()
	init_enemy()

func init_debuff_scenes() -> void:
	weakened_debuff_effect = load("res://Entities/weakened_debuff.tscn").instantiate()
	add_child(weakened_debuff_effect)
	weakened_debuff_effect.emitting = false
	
	onfire_debuff_effect = load("res://Entities/onfire_debuff.tscn").instantiate()
	add_child(onfire_debuff_effect)
	onfire_debuff_effect.emitting = false

func init_enemy_data() -> void:
	pass

@abstract
func init_enemy() -> void

func recieve_damage(dmg: float, incoming_knockback: float, src_position: Vector2) -> void:
	var incoming_damage: float = dmg
	health -= incoming_damage
	
	if incoming_knockback != -1:
		var knockback_direction = global_position - src_position
		incoming_knockback = maxf(60.0, incoming_knockback - knockback_resist)
		knockback_velocity = sign(knockback_direction.x) * incoming_knockback
		velocity.y = -incoming_knockback * 0.5
	
	if health <= 0:
		enemy_death()

func recieve_debuff(debuff: GameData.Debuffs, duration: float) -> void:
	var db_tween: SceneTreeTimer = get_tree().create_timer(duration)
	db_tween.timeout.connect(remove_debuff.bind(debuff))
	debuffs_stack.append(debuff)
	check_debuffs()

func remove_debuff(debuff: GameData.Debuffs) -> void:
	debuffs_stack.erase(debuff)
	check_debuffs()

func check_debuffs() -> void:
	weakened_debuff_effect.emitting = debuffs_stack.has(GameData.Debuffs.Weakened)
	
	onfire_debuff_effect.emitting = debuffs_stack.has(GameData.Debuffs.OnFire)
	onfire_debuff_effect.get_node("PointLight2D").visible = debuffs_stack.has(GameData.Debuffs.OnFire)
	
	health = GameTools.round_to_dec(health, 2)
	recieve_damage(0, -1, Vector2(0,0))

func enemy_death():
	if is_dead: 
		return
	is_dead = true
	
	attack_area.set_deferred("monitoring", false)
	
	var es = GameData.EssenceScene.instantiate()
	get_tree().current_scene.call_deferred("add_child", es)
	es.position = global_position
	get_tree().create_tween().tween_property(es, "position", Vector2(global_position.x, global_position.y - 15), 0.5)
	
	await get_tree().create_tween().tween_method(func(v: float): anin_sprite.material.set_shader_parameter("progress", v), 0.2, 1.0, 0.5).finished
	
	queue_free()

func locate_target():
	target = get_tree().current_scene.get_node_or_null("Player")

@abstract
func movement_handling(delta: float) -> void

@abstract
func summon_enemy() -> void

func _physics_process(delta: float) -> void:
	if target == null and not is_dead:
		locate_target()
		return
	
	# OnFire debuff does passive damage every tick that adds up to Rate/sec overall 
	if debuffs_stack.has(GameData.Debuffs.OnFire):
		recieve_damage(onfire_damage_rate * delta, -1, Vector2.ZERO)
	
	movement_handling(delta)
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	knockback_velocity = move_toward(knockback_velocity, 0.0, knockback_friction * delta)
	
	velocity.x += knockback_velocity
	move_and_slide()
	velocity.x -= knockback_velocity

func update_animation(direction: float) -> void:
	if not is_on_floor():
		if anin_sprite.animation != "midair":
			anin_sprite.play("midair")
		return
	
	if direction != 0:
		anin_sprite.flip_h = direction > 0
		anin_sprite.play("walk")
	else:
		anin_sprite.play("idle")

func attack_area_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		var incoming_damage: float = contact_damage
		
		if debuffs_stack.has(GameData.Debuffs.Weakened):
			incoming_damage /= 2.0
		
		area.get_parent().recieve_damage(incoming_damage, knockback_force, global_position)
