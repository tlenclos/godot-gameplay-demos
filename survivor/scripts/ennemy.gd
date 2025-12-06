extends CharacterBody3D

@export var speed: float = 3.0
@export var acceleration: float = 5.0
@export var detection_range: float = 50.0
@export var max_health: float = 30.0

var health: float
var target: Node3D
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
const XP = preload("uid://tyjwyvs4aiso")

signal died

func _ready() -> void:
	health = max_health
	
	# Add to enemy group for detection
	add_to_group("enemies")
	
	# Find the player
	target = get_tree().get_first_node_in_group("player")
	if not target:
		var parent = get_parent()
		while parent:
			target = parent.get_node_or_null("Player")
			if target:
				break
			parent = parent.get_parent()

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if not target or not is_instance_valid(target):
		return
	
	# Calculate direction to player
	var direction = (target.global_position - global_position)
	direction.y = 0 # Keep movement horizontal
	var distance = direction.length()
	
	if distance > 0.5 and distance < detection_range:
		direction = direction.normalized()
		
		# Smoothly accelerate toward target
		velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * speed, acceleration * delta)
		
		# Rotate to face player
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 8.0 * delta)
	else:
		# Stop when close or out of range
		velocity.x = move_toward(velocity.x, 0, acceleration * delta)
		velocity.z = move_toward(velocity.z, 0, acceleration * delta)
	
	move_and_slide()

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	# Spawn XP at current position
	var spawn_pos = global_position
	var xp = XP.instantiate()
	
	if target and is_instance_valid(target):
		target.get_parent().add_child(xp)
	else:
		get_tree().root.add_child(xp)
	xp.global_position = spawn_pos
	
	died.emit()
	queue_free()
