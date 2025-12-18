extends Node3D

signal game_ended

const INTERACTION_SCENES: Dictionary = {
	"Chest": preload("res://escape/scenes/treasure_lock.tscn"),
}

var current_interaction_scene: Control = null

@onready var player: CharacterBody3D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var chest: Node3D = $Room/chest
@onready var key: Node3D = $Room/key

func _ready() -> void:
	player.interacted.connect(_on_player_interacted)

func _input(event: InputEvent) -> void:
	# Close interaction scene with Escape key
	if event.is_action_pressed("ui_cancel") and current_interaction_scene:
		_close_interaction_scene()
		get_viewport().set_input_as_handled()

func _on_player_interacted(target: Node) -> void:
	print("Player interact with " + target.name)
	# Collect key
	if target.name == "Key":
		player.add_item("Key")
		key.queue_free()
		return
		
	# Handle door interaction
	if target.name == "door":
		if player.has_item("Key"):
			player.remove_item("Key")
			target.open()
			print("Door unlocked! You escaped!")
			await get_tree().create_timer(1).timeout
			game_ended.emit()
		else:
			print("The door is locked. You need a key.")
		return
	
	# Or open interaction scene
	var scene_resource = INTERACTION_SCENES.get(target.name)
	if scene_resource:
		_open_interaction_scene(scene_resource, target)

func _open_interaction_scene(scene_resource: PackedScene, target: Node) -> void:
	if current_interaction_scene:
		return
	
	# Instantiate and add the 2D scene
	current_interaction_scene = scene_resource.instantiate()
	hud.add_child(current_interaction_scene)
	
	# Freeze player movement
	player.set_interacting(true)
	
	# Connect to common signals (if the scene has them)
	if current_interaction_scene.has_signal("unlocked"):
		current_interaction_scene.unlocked.connect(_on_puzzle_completed.bind(target))
	if current_interaction_scene.has_signal("closed"):
		current_interaction_scene.closed.connect(_close_interaction_scene)

func _close_interaction_scene() -> void:
	if current_interaction_scene:
		current_interaction_scene.queue_free()
		current_interaction_scene = null
		player.set_interacting(false)

func _on_puzzle_completed(target: Node) -> void:
	# Handle puzzle completion - you can customize this per puzzle
	print("Puzzle completed for: ", target.name)
	
	# Close the interaction scene after a delay
	await get_tree().create_timer(0.5).timeout
	_close_interaction_scene()
	
	# Open the chest when puzzle is solved
	if target.name == "Chest":
		target.open()
