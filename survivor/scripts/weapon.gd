class_name Weapon
extends Node3D

enum WeaponType {DIRECT, ZONE}

@export_group("Weapon Stats")
@export var damage: float = 10.0
@export var velocity: float = 15.0
@export var level: int = 1
@export var weapon_type: WeaponType = WeaponType.DIRECT

@export_group("Timing")
@export var cooldown: float = 0.5
@export var projectile_lifetime: float = 10.0
@export var auto_fire: bool = true

@export_group("Zone Settings")
@export var zone_radius: float = 3.0
@export var zone_duration: float = 1.0

@export_group("Visuals")
@export var projectile_color: Color = Color(1.0, 0.8, 0.2)
@export var projectile_size: float = 0.15

var can_fire: bool = true

signal enemy_hit(enemy: Node3D, damage: float)

func _physics_process(_delta: float) -> void:
	if auto_fire and can_fire:
		var target = _find_nearest_enemy()
		if target:
			var direction = (target.global_position - global_position).normalized()
			fire(direction)

func fire(direction: Vector3) -> void:
	if not can_fire:
		return
	
	can_fire = false
	
	match weapon_type:
		WeaponType.DIRECT:
			_fire_direct(direction)
		WeaponType.ZONE:
			_fire_zone()
	
	# Start cooldown
	get_tree().create_timer(cooldown / level).timeout.connect(_reset_cooldown)

func _fire_direct(direction: Vector3) -> void:
	var projectile = Projectile.new()
	projectile.direction = direction.normalized()
	projectile.speed = velocity
	projectile.damage = damage * level
	projectile.lifetime = projectile_lifetime
	projectile.hit_enemy.connect(_on_projectile_hit)
	
	# Add mesh
	var mesh_instance = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = projectile_size
	sphere.height = projectile_size * 2
	mesh_instance.mesh = sphere
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = projectile_color
	mat.emission_enabled = true
	mat.emission = projectile_color
	mat.emission_energy_multiplier = 0.5
	mesh_instance.material_override = mat
	projectile.add_child(mesh_instance)
	
	# Add collision
	var collision = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = projectile_size
	collision.shape = shape
	projectile.add_child(collision)
	
	projectile.global_position = global_position + direction.normalized() * 0.8
	get_tree().root.add_child(projectile)

func _fire_zone() -> void:
	# Create visual
	var zone = Node3D.new()
	zone.name = "DamageZone"
	zone.global_position = global_position
	
	var mesh_instance = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = zone_radius
	cylinder.bottom_radius = zone_radius
	cylinder.height = 0.1
	mesh_instance.mesh = cylinder
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(projectile_color, 0.5)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = projectile_color
	mat.emission_energy_multiplier = 2.0
	mesh_instance.material_override = mat
	zone.add_child(mesh_instance)
	
	get_tree().root.add_child(zone)
	
	# Deal damage
	_apply_zone_damage(zone.global_position)
	
	# Cleanup
	get_tree().create_timer(zone_duration).timeout.connect(zone.queue_free)

func _apply_zone_damage(center: Vector3) -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var distance = enemy.global_position.distance_to(center)
		if distance <= zone_radius:
			var falloff = 1.0 - (distance / zone_radius) * 0.5
			var final_damage = damage * level * falloff
			enemy_hit.emit(enemy, final_damage)
			if enemy.has_method("take_damage"):
				enemy.take_damage(final_damage)

func _find_nearest_enemy() -> Node3D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest: Node3D = null
	var nearest_dist: float = INF
	
	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy
	
	return nearest

func _on_projectile_hit(enemy: Node3D, dmg: float) -> void:
	enemy_hit.emit(enemy, dmg)

func _reset_cooldown() -> void:
	can_fire = true

func upgrade() -> void:
	level += 1
