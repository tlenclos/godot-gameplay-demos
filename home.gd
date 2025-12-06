extends Control

var current_game_scene: Node = null

func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and current_game_scene:
		current_game_scene.queue_free()
		current_game_scene = null
		show()

func _load_scene(game_scene: PackedScene):
	current_game_scene = game_scene.instantiate()
	get_parent().add_child(current_game_scene)
	hide()

func _on_rogue_like_pressed() -> void:
	_load_scene(preload("res://survivor/survivor.tscn"))

func _on_race_pressed() -> void:
	_load_scene(preload("res://race/race.tscn"))
