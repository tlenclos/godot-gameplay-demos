extends StaticBody3D

var is_open: bool = false

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

func _ready() -> void:
	animation_player.set_assigned_animation("close")

func open() -> void:
	print("OPEN CHEST")
	if is_open:
		return
	
	is_open = true
	animation_player.play("open")
	remove_from_group("interactable")
	
	# Remove from collision layer 2 after opening
	collision_layer = collision_layer & ~2 
