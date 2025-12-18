extends Node3D

@export var label_text: String = "1":
	set(value):
		label_text = value
		_update_label()

@export var label_color: Color = Color.WHITE:
	set(value):
		label_color = value
		_update_label()

@onready var label: Label3D = $Label3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_label()

func _update_label() -> void:
	if label:
		label.text = label_text
		label.modulate = label_color
