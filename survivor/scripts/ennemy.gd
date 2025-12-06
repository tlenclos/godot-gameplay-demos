extends CharacterBody3D

@export var speed: float = 3.0
@export var acceleration: float = 5.0
@export var detection_range: float = 50.0
@export var climb_jump_force: float = 5.0
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
	
	if not target:
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
	
	# Check for collisions with other enemies and climb them
	_check_enemy_collision()

func _check_enemy_collision() -> void:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Check if we hit another enemy
		if collider and collider.is_in_group("enemies") and collider != self:
			var collision_normal = collision.get_normal()
			
			# If collision is mostly horizontal (we're bumping into them, not landing on them)
			if abs(collision_normal.y) < 0.5:
				# Jump to climb over
				if is_on_floor() or _is_on_enemy():
					velocity.y = climb_jump_force

func _is_on_enemy() -> bool:
	# Check if standing on another enemy
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.is_in_group("enemies") and collider != self:
			var normal = collision.get_normal()
			# If normal points up, we're standing on them
			if normal.y > 0.7:
				return true
	return false

func take_damage(amount: float) -> void:
	health -= amount
	
	# Flash red on hit
	_flash_damage()
	
	if health <= 0:
		die()

func _flash_damage() -> void:
	var body_mesh = get_node_or_null("Body")
	if body_mesh and body_mesh is MeshInstance3D:
		var original_material = body_mesh.get_surface_override_material(0)
		if original_material:
			var flash_mat = original_material.duplicate()
			flash_mat.albedo_color = Color(1.0, 0.2, 0.2)
			body_mesh.set_surface_override_material(0, flash_mat)
			
			await get_tree().create_timer(0.1).timeout
			if is_instance_valid(self) and is_instance_valid(body_mesh):
				body_mesh.set_surface_override_material(0, original_material)

func die() -> void:
	var xp = XP.instantiate()
	target.get_parent().add_child(xp)
	xp.global_position = global_position
	
	died.emit()
	queue_free()
