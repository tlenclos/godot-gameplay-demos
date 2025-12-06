extends Camera3D

@export var target: Node3D
@export var smoothness: float = 5.0
@export var offset: Vector3 = Vector3(0, 8, 8)

func _ready() -> void:
	# Find player automatically if not set
	if not target:
		target = get_tree().get_first_node_in_group("player")
		if not target:
			target = get_parent().get_node_or_null("Player")

func _physics_process(delta: float) -> void:
	if not target:
		return
	
	var target_position = target.global_position + offset
	global_position = global_position.lerp(target_position, smoothness * delta)



