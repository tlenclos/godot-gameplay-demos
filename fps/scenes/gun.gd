extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func shoot() -> void:
	animation_player.play("shoot")
