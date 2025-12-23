extends Control

signal card_dropped(card: Node2D)

var slot_size: Vector2 = Vector2(200, 280) # Slightly larger than a card

func _ready() -> void:
	custom_minimum_size = slot_size

func is_point_inside(point: Vector2) -> bool:
	# point is in screen coordinates (from CanvasLayer)
	# Convert to local coordinates
	var local_point = point - global_position
	var rect = Rect2(Vector2.ZERO, slot_size)
	return rect.has_point(local_point)
