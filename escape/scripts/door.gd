extends Node3D

@onready var animation_player: AnimationPlayer = $"../../../AnimationPlayer"

func open() -> void:
	print(str(animation_player.get_animation_list()))
	animation_player.play('open')
