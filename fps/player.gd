extends CharacterBody3D

## TODO shoot feedback (animate gun, sparks)
## TODO Player movement / control feeling

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.003
var is_paused: bool = false

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var target_name: Label = $"../HUD/TargetName"
@onready var controls_panel: Control = $"../HUD/ControlsPanel"
@onready var gun: Node3D = $Head/Camera3D/Gun
@onready var bullet_collision_effect: GPUParticles3D = $"../BulletCollisionEffect"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	if is_paused:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()
	
func _input(event):
	# Toggle pause with P key
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		toggle_pause()
		get_viewport().set_input_as_handled()
		return
	
	if is_paused:
		return
	
	# Shoot on click
	if event is InputEventMouseButton and event.pressed:
		shoot()
	# Camera movement
	elif event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func shoot() -> void:
	
	# Send ray to check collision
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(camera.global_position, camera.global_position - camera.global_transform.basis.z * 100)
	var collision = space.intersect_ray(query)
	
	if collision:
		target_name.text = "Hit : " + collision.collider.name
		gun.shoot()
		_bullet_collision_effect(collision)
		if collision.collider.is_in_group("target"):
			collision.collider.queue_free()
	else:
		target_name.text = ""

func toggle_pause() -> void:
	is_paused = !is_paused
	
	if is_paused:
		# Pause the game
		get_tree().paused = true
		# Release mouse control
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		# Show controls panel
		controls_panel.visible = true
	else:
		# Unpause the game
		get_tree().paused = false
		# Capture mouse control
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		# Hide controls panel
		controls_panel.visible = false

func _bullet_collision_effect(collision) -> void:
	# Effect position, and oriented toward the player
	bullet_collision_effect.global_position = collision.position
	bullet_collision_effect.look_at(camera.global_position, Vector3.UP)
	
	# Duration control
	bullet_collision_effect.restart()
	bullet_collision_effect.emitting = true
	await get_tree().create_timer(0.2).timeout
	bullet_collision_effect.emitting = false
