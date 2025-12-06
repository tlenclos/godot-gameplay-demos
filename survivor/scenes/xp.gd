extends Node3D

var player: Node3D
var current_speed: float = 0.0
var magnet_player: bool = false

@export var max_speed: float = 15.0
@export var acceleration: float = 20.0
@export var pickup_distance: float = 0.8
@export var detection_range: float = 5.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	await get_tree().create_timer(0.5).timeout
	magnet_player = true

func _process(delta: float) -> void:
	if not player or not magnet_player:
		return
	
	var direction = player.global_position - global_position
	var distance = direction.length()
	
	if distance > 0.5 and distance < detection_range:
		# Accelerate toward player
		current_speed = min(current_speed + acceleration * delta, max_speed)
		
		# Move toward player
		if distance > 0.1:
			direction = direction.normalized()
			global_position += direction * current_speed * delta
		
		# Pickup when close
		if distance < pickup_distance:
			_on_pickup()

func _on_pickup() -> void:
	if player.has_method("add_xp"):
		player.add_xp(1)
	queue_free()
