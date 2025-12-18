extends CharacterBody3D

signal interacted(target: Node)

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const RAY_LENGTH_METERS = 2

var is_interacting: bool = false
var inventory: Array[String] = []

@export var mouse_sensitivity: float = 0.003
@export var interactable_group: String = "interactable"

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var target_name: Label = $"../HUD/TargetName"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func set_interacting(value: bool) -> void:
	is_interacting = value
	if is_interacting:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	if is_interacting:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()
	
	# Check interact object
	var target = _target_interact()
	if target and target.collider.is_in_group(interactable_group):
		target_name.text = "[E] " + target.collider.name
		target_name.visible = true
	else:
		target_name.visible = false

func _target_interact() -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()

	var origin = camera.project_ray_origin(mousepos)
	var end = origin + camera.project_ray_normal(mousepos) * RAY_LENGTH_METERS
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	# Only scan for collision layer 2, this is needed to disable detection for some objects after interaction while keeping collision
	query.collision_mask = 2

	return space_state.intersect_ray(query)
	
func _input(event: InputEvent) -> void:
	if is_interacting:
		return
	
	# Interact with E key or left click
	if event.is_action_pressed("interact") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		var target = _target_interact()
		if target and target.collider.is_in_group(interactable_group):
			interacted.emit(target.collider)
			return
	
	# Camera movement
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(60))

func has_item(item_name: String) -> bool:
	return item_name in inventory

func add_item(item_name: String) -> void:
	if not has_item(item_name):
		inventory.append(item_name)
		print("Collected: ", item_name)

func remove_item(item_name: String) -> void:
	var index = inventory.find(item_name)
	if index != -1:
		inventory.remove_at(index)
