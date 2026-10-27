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
var essence_scene = load("res://Prototype/Scenes/GameScene/Essence.tscn")

@export var accel_speed = 500
@export var max_speed = 80

func _ready() -> void:
	attack_area.connect("area_entered", attack_area_area_entered)

func recieve_damage(dmg: float, incoming_knockback: float, src_position: Vector2) -> void:
	health -= dmg
	incoming_knockback = maxf(0.0, incoming_knockback - knockback_resist)
	
	var knockback_direction = global_position - src_position
	knockback_velocity = sign(knockback_direction.x) * incoming_knockback
	velocity.y = -incoming_knockback * 0.5
	
	if health <= 0:
		enemy_death()

func enemy_death():
	if is_dead: return
	
	attack_area.set_deferred("monitoring", false)
	get_tree().current_scene.enemy_count -= 1
	is_dead = true
	
	var es = essence_scene.instantiate()
	get_tree().current_scene.call_deferred("add_child", es)
	es.position = global_position
	get_tree().create_tween().tween_property(es, "position", Vector2(global_position.x, global_position.y - 15), 0.5)
	
	anin_sprite.material = anin_sprite.material.duplicate(true)
	await get_tree().create_tween().tween_method(func(v: float): anin_sprite.material.set_shader_parameter("progress", v), 0.2, 1.0, 0.5).finished
	
	queue_free()

func locate_target():
	target = get_tree().current_scene.get_node_or_null("Player")

@abstract
func movement_handling(delta: float) -> void

@abstract
func summon_enemy() -> void

func _physics_process(delta: float) -> void:
	if target == null:
		locate_target()
		return
	
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
		area.get_parent().recieve_damage(contact_damage, knockback_force, global_position)
