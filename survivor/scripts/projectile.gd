class_name Projectile
extends CharacterBody3D

var direction: Vector3 = Vector3.FORWARD
var speed: float = 15.0
var damage: float = 10.0
var lifetime: float = 3.0
var time_alive: float = 0.0

signal hit_enemy(enemy: Node3D, damage: float)

func _ready() -> void:
	# Set collision layer to 4 (projectiles)
	collision_layer = 8 # Layer 4
	# Only collide with layer 3 (enemies) and layer 1 (world)
	collision_mask = 5 # Layers 1 + 3

func _physics_process(delta: float) -> void:
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()
		return
	
	velocity = direction * speed
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var collider = collision.get_collider()
		
		if collider and collider.is_in_group("enemies"):
			hit_enemy.emit(collider, damage)
			if collider.has_method("take_damage"):
				collider.take_damage(damage)
			queue_free()
		elif collider and not collider.is_in_group("player"):
			queue_free()
